use axum::response::IntoResponse;

pub(crate) async fn signin_handler() -> impl IntoResponse {
    "sigin"
}

pub(crate) async fn signup_handler() -> impl IntoResponse {
    "signup"
}
