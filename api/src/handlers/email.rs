use sparkpost::transmission;

use crate::errors;
use crate::models;
use crate::utils;

lazy_static::lazy_static! {
    static ref API_KEY: String = utils::env_var("SPARKPOST_API_KEY");
}

pub fn send(invitation: &models::Invitation) -> Result<(), errors::ServiceError> {
    let tm = transmission::Transmission::new(API_KEY.as_str());
    let sender = utils::env_var("APP_NAME");
    let sending_addr = utils::env_var("SENDING_EMAIL_ADDRESS");
    let mut email = transmission::Message::new(
        transmission::EmailAddress::new(sending_addr, sender)
    );
    // recipient from the invitation email
    let recipient: transmission::Recipient = invitation.email.as_str().into();

    // let options = transmission::Options {
    //     open_tracking: false,
    //     click_tracking: false,
    //     transactional: true,
    //     sandbox: false,
    //     inline_css: false,
    //     start_time: None,
    // };

    let email_body = format!("\
        Your register key is: <br>
        <span style=\"font-size: x-large; font-weight: bold;\">{}</span> <br>
        The key expires on: <br>
        <span style=\"font-weight: bold;\">{}</span> <br>
        ",
        invitation.id,
        invitation.expires_at
            .format("%I:%M %p %A, %-d %B, %C%y")
            .to_string()
    );

    // complete the email message with details
    email
        .add_recipient(recipient)
        // .options(options)
        .subject(format!("Invitation to {}", utils::env_var("APP_NAME")))
        .html(email_body);

    let result = tm.send(&email);

    // note that we only print out the error response from email api
    match result {
        Ok(res) => match res {
            transmission::TransmissionResponse::ApiResponse(api_res) => {
                println!("API Response: \n {:#?}", api_res);
                Ok(())
            }
            transmission::TransmissionResponse::ApiError(errors) => {
                println!("Response Errors: \n {:#?}", &errors);
                Err(errors::ServiceError::InternalServerError)
            }
        },
        Err(error) => {
            println!("Send Email Error: \n {:#?}", error);
            Err(errors::ServiceError::InternalServerError)
        }
    }
}
