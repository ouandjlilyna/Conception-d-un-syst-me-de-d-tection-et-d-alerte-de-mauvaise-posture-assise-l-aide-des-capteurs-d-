
#include <stdint.h>
#include <string.h>
#include "ble.h"
#include "nrf_gpio.h"
#include "ble_MyoWar.h"
#include "ble_srv_common.h"
#include "app_error.h"




   
static uint32_t sensor_char_add(ble_MyoWar_t * p_MyoWar)
{  
   //Use custom UUID to define characteristic value type
 uint32_t            err_code;
ble_uuid_t          char_uuid;
ble_uuid128_t       base_uuid = BLE_UUID_OUR_BASE_UUID;


char_uuid.type      = p_MyoWar->uuid_type;
char_uuid.uuid      = BLE_UUID_OUR_CHARACTERISTC_UUID;

  
ble_gatts_attr_md_t attr_md;
ble_gatts_char_md_t char_md;
ble_gatts_attr_t    attr_char_value;

memset(&attr_md, 0, sizeof(attr_md));
attr_md.vloc        = BLE_GATTS_VLOC_STACK;

  //Configure the Characteristic Value Attribute

memset(&attr_char_value, 0, sizeof(attr_char_value));    
attr_char_value.p_uuid      = &char_uuid;
attr_char_value.p_attr_md   = &attr_md;
 
  //Add read/write properties to our characteristic value
memset(&char_md, 0, sizeof(char_md));
char_md.char_props.read = 1;
char_md.char_props.write = 1;


     // Configuring CCCD metadata
ble_gatts_attr_md_t cccd_md;
memset(&cccd_md, 0, sizeof(cccd_md));
BLE_GAP_CONN_SEC_MODE_SET_OPEN(&cccd_md.read_perm);
BLE_GAP_CONN_SEC_MODE_SET_OPEN(&cccd_md.write_perm);
cccd_md.vloc                = BLE_GATTS_VLOC_STACK;    
char_md.p_cccd_md           = &cccd_md;
char_md.char_props.notify   = 1;



  //Set read/write permissions to our characteristic
BLE_GAP_CONN_SEC_MODE_SET_OPEN(&attr_md.read_perm);
BLE_GAP_CONN_SEC_MODE_SET_OPEN(&attr_md.write_perm);

   //Set characteristic length
attr_char_value.max_len     = 2;   
attr_char_value.init_len    = 2;
 
  // Add the new characteristic to the service
err_code = sd_ble_gatts_characteristic_add(p_MyoWar->service_handle,
                                   &char_md,
                                   &attr_char_value,
                                   &p_MyoWar->char_handles);
APP_ERROR_CHECK(err_code);
 
    return err_code ;

}


void MyoWar_init(ble_MyoWar_t * p_MyoWar)
{
  //Add UUIDs to BLE stack table
uint32_t           err_code;
ble_uuid_t        service_uuid;
ble_uuid128_t     base_uuid = BLE_UUID_OUR_BASE_UUID;
service_uuid.uuid = BLE_UUID_MyoWar;

err_code = sd_ble_uuid_vs_add(&base_uuid, &service_uuid.type);

APP_ERROR_CHECK(err_code);



  //Give our service connection handle a default value
p_MyoWar->conn_handle = BLE_CONN_HANDLE_INVALID;



   //Add our service
err_code = sd_ble_gatts_service_add(BLE_GATTS_SRVC_TYPE_PRIMARY,
                                    &service_uuid,
                                    &p_MyoWar->service_handle);
APP_ERROR_CHECK(err_code);

p_MyoWar->uuid_type= service_uuid.type;

  //Add the Characteristic
err_code = sensor_char_add(p_MyoWar);
APP_ERROR_CHECK(err_code);

}


uint32_t our_sensor_characteristic_update(uint16_t conn_handle ,ble_MyoWar_t *p_MyoWar,int16_t sensor_value)//nrf_saadc_value_t sensor_value) // 
{   
   //Update characteristic value
uint16_t               len = sizeof(sensor_value);
ble_gatts_hvx_params_t hvx_params;
memset(&hvx_params, 0, sizeof(hvx_params));

hvx_params.handle = p_MyoWar->char_handles.value_handle;
hvx_params.type   = BLE_GATT_HVX_NOTIFICATION;
hvx_params.p_len  = &len;
hvx_params.p_data = (uint8_t*)&sensor_value;  

return sd_ble_gatts_hvx(conn_handle, &hvx_params);

}



