use actix_web::{error::BlockingError, web, HttpResponse};
use diesel::prelude::*;
use serde::Deserialize;

use crate::schema::users;
use crate::models;
use crate::errors;
use crate::utils;

#[derive(Deserialize)]
pub struct ReqUser {
    pub key: uuid::Uuid,
    pub email: String,
    pub password: String,
}

#[derive(Insertable)]
#[table_name = "users"]
pub struct NewUser {
    pub email: String,
    pub hash: String,
}

impl ReqUser {
    fn pass(&self, pool: &web::Data<models::Pool>) -> Result<NewUser, errors::ServiceError> {
        self.validate(pool)?;
        Ok(NewUser {
            email: self.email.to_owned(),
            hash: utils::hash(&self.password)?,
        })
    }
    fn validate(&self, pool: &web::Data<models::Pool>) -> Result<(), errors::ServiceError> {
        use crate::schema::invitations::dsl::{invitations, email};

        let conn = pool.get().unwrap();
        if let Some(invitation) = invitations
            .find(&self.key)
            .filter(email.eq(&self.email))
            .load::<models::Invitation>(&conn)?
            .pop() {
                if chrono::Utc::now() < invitation.expires_at {
                    return Ok(())
                }
                return Err(errors::ServiceError::BadRequest("invitation expired".into()))
            }
        Err(errors::ServiceError::BadRequest("invitation invalid".into()))
    }
}

pub async fn register(
    req_user: web::Json<ReqUser>,
    pool: web::Data<models::Pool>,
) -> Result<HttpResponse, errors::ServiceError> {

    let res = web::block(move || {
        use crate::schema::users::dsl::users;

        let new_user = req_user.into_inner().pass(&pool)?;
        let conn = pool.get().unwrap();
        let user: models::User = diesel::insert_into(users).values(&new_user).get_result(&conn)?;
        Ok(models::SlimUser::from(user))
    }
    ).await;

    match res {
        Ok(slim_user) => Ok(HttpResponse::Ok().json(&slim_user)),
        Err(err) => match err {
            BlockingError::Error(service_error) => Err(service_error),
            BlockingError::Canceled => Err(errors::ServiceError::InternalServerError),
        },
    }
}
