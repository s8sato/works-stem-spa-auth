use actix_web::{error::BlockingError, web, HttpResponse};
use diesel::prelude::*;
use serde::Deserialize;

use crate::errors;
use crate::models;
use crate::utils;

#[derive(Debug, Deserialize)]
pub struct UserData {
    pub email: String,
    pub password: String,
}

pub async fn register(
    invitation_id: web::Path<String>,
    user_data: web::Json<UserData>,
    pool: web::Data<models::Pool>,
) -> Result<HttpResponse, errors::ServiceError> {

    let res = web::block(move ||
        query(invitation_id.into_inner(), user_data.into_inner(), pool)
    ).await;

    match res {
        Ok(user) => Ok(HttpResponse::Ok().json(&user)),
        Err(err) => match err {
            BlockingError::Error(service_error) => Err(service_error),
            BlockingError::Canceled => Err(errors::ServiceError::InternalServerError),
        },
    }
}

fn query(
    invitation_id: String,
    user_data: UserData,
    pool: web::Data<models::Pool>,
) -> Result<models::SlimUser, errors::ServiceError> {
    use crate::schema::invitations::dsl::{email, id, invitations};
    use crate::schema::users::dsl::users;

    let invitation_id = uuid::Uuid::parse_str(&invitation_id)?;
    let conn: &PgConnection = &pool.get().unwrap();

    invitations
        .filter(id.eq(invitation_id))
        .filter(email.eq(&user_data.email))
        .load::<models::Invitation>(conn)
        .map_err(|_db_error| errors::ServiceError::BadRequest("Invalid Invitation".into()))
        .and_then(|mut result| {
            if let Some(invitation) = result.pop() {
                // if invitation is not expired
                if invitation.expires_at > chrono::Local::now().naive_local() {
                    // try hashing the password, else return the error that will be converted to ServiceError
                    let password: String = utils::hash_password(&user_data.password)?;
                    let user = models::User::from_details(invitation.email, password);
                    let inserted_user: models::User =
                        diesel::insert_into(users).values(&user).get_result(conn)?;
                    dbg!(&inserted_user);
                    return Ok(inserted_user.into());
                }
            }
            Err(errors::ServiceError::BadRequest("Invalid Invitation".into()))
        })
}
