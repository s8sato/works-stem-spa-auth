use actix_web::{error::BlockingError, web, HttpResponse};
use diesel::{prelude::*, PgConnection};
use serde::Deserialize;

use super::email;
use crate::errors;
use crate::models;

#[derive(Deserialize)]
pub struct InvitationData {
    pub email: String,
}

pub async fn invite(
    invitation_data: web::Json<InvitationData>,
    pool: web::Data<models::Pool>,
) -> Result<HttpResponse, errors::ServiceError> {
    // run diesel blocking code
    let res = web::block(move || {
        let invitation = dbg!(query(invitation_data.into_inner().email, pool)?);
        email::send(&invitation)
    }).await;

    match res {
        Ok(_) => Ok(HttpResponse::Ok().finish()),
        Err(err) => match err {
            BlockingError::Error(service_error) => Err(service_error),
            BlockingError::Canceled => Err(errors::ServiceError::InternalServerError),
        },
    }
}

fn query(
    email: String,
    pool: web::Data<models::Pool>
) -> Result<models::Invitation, errors::ServiceError> {
    use crate::schema::invitations::dsl::invitations;

    let new_invitation: models::Invitation = email.into();
    let conn: &PgConnection = &pool.get().unwrap();

    let inserted_invitation = diesel::insert_into(invitations)
        .values(&new_invitation)
        .get_result(conn)?;

    Ok(inserted_invitation)
}
