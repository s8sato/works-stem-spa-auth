use diesel::{r2d2::ConnectionManager, PgConnection};
use chrono::{DateTime, Utc};
use serde::{Serialize, Deserialize}; // TODO remove

use super::schema::*;

pub type Pool = r2d2::Pool<ConnectionManager<PgConnection>>;
pub type Conn = r2d2::PooledConnection<ConnectionManager<PgConnection>>;

#[derive(Queryable, Identifiable, Insertable, Debug)]
pub struct Invitation {
    pub id: uuid::Uuid,
    pub email: String,
    pub expires_at: DateTime<Utc>,
    pub forgot_pw: bool,
}

#[derive(Queryable, Identifiable)]
pub struct User {
    pub id: i32,
    pub email: String,
    pub hash: String,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct SlimUser {
    pub email: String,
}

impl From<User> for SlimUser {
    fn from(user: User) -> Self {
        SlimUser { email: user.email }
    }
}
