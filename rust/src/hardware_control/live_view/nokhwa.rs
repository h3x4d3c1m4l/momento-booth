use derive_more::{From, Into};
use nokhwa::{utils::{CameraInfo, RequestedFormat, RequestedFormatType}, query, native_api_backend, nokhwa_initialize, CallbackCamera, pixel_format::RgbAFormat};

use crate::{dart_bridge::api::RawImage, log_debug, log_info, log_error};

pub fn initialize<F>(on_complete: F) where F: Fn(bool) + std::marker::Send + std::marker::Sync + 'static {
    if cfg!(target_os = "macos") {
        nokhwa_initialize(on_complete);
    } else {
        on_complete(true);
    }
}

pub fn get_cameras() -> Vec<NokhwaCameraInfo> {
    let backend = native_api_backend().expect("Could not get backend");
    let devices = query(backend).expect("Could not query backend");

    let device_names: Vec<NokhwaCameraInfo> = devices.iter().map(NokhwaCameraInfo::from_camera_info).collect();
    device_names
}

pub fn open_camera(friendly_name: String) -> CallbackCamera {
    log_debug("nokhwa::open_camera() opening '".to_string() + &friendly_name + "'");
    let format = RequestedFormat::new::<RgbAFormat>(RequestedFormatType::AbsoluteHighestResolution);
    
    // Look up device name
    let backend = native_api_backend().expect("Could not get backend");
    let devices = query(backend).expect("Could not query backend");
    let camera_info = devices.into_iter().find(|device| device.human_name() == friendly_name).expect("Could not find camera");

    let mut camera = CallbackCamera::new(camera_info.index().clone(), format, |_| {}).expect("Could not create CallbackCamera");

    camera.open_stream().expect("Could not open camera stream");
    let camera_format_str = &camera.camera_format().expect("Could not get camera format").to_string();
    log_info("nokhwa::open_camera() opened '".to_string() + &friendly_name + "' (" + camera_format_str + ")");

    camera
}

pub fn set_camera_callback<F>(camera: &mut CallbackCamera, frame_callback: F) where F: Fn(Option<RawImage>) + Send + Sync + 'static {
    log_debug("nokhwa::set_camera_callback() setting callback for '".to_string() + &camera.info().human_name() + "'");
    camera.set_callback(move |buffer| {
        let raw_rgba_image = buffer.decode_image::<RgbAFormat>();
        let raw_image_option = match raw_rgba_image {
            Ok(x) => {
                Some(RawImage::new_from_rgba_data(
                    x.to_vec(),
                    buffer.resolution().width() as usize,
                    buffer.resolution().height() as usize,
                ))
            },
            Err(err) => {
                log_error("Image decoding error: ".to_string() + &err.to_string());
                None
            },
        };

        frame_callback(raw_image_option);
    }).expect("Failed setting the callback");
    log_debug("nokhwa::set_camera_callback() callback set for '".to_string() + &camera.info().human_name() + "'");
}

pub fn close_camera(camera: CallbackCamera) {
    let camera_name = camera.info().human_name();
    drop(camera);
    log_info("nokhwa::close_camera() dropped '".to_string() + &camera_name + "'");
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, From, Into)]
struct Id(usize);

// /////// //
// Structs //
// /////// //

pub struct NokhwaCameraInfo {
    pub id: u32,
    pub friendly_name: String,
}

impl NokhwaCameraInfo {
    pub fn from_camera_info(camera_info: &CameraInfo) -> Self {
        Self { id: camera_info.index().as_index().expect("Could not get camera index"), friendly_name: camera_info.human_name() }
    }
}
