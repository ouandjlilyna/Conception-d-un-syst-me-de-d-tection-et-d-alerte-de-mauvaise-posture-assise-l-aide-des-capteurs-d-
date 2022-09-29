
#include <stdint.h>
#include "ble.h"
#include "ble_srv_common.h"
#include "nrf_drv_saadc.h"



// FROM_SERVICE_TUTORIAL: Defining 16-bit service and 128-bit base UUIDs
#define BLE_UUID_OUR_BASE_UUID  {{0x23, 0xD1, 0x13, 0xEF, 0x5F, 0x78, 0x23, 0x15, 0xDE, 0xEF, 0x12, 0x12, 0x00, 0x00, 0x00, 0x00}} // 128-bit base UUID
#define BLE_UUID_MyoWar              0xF00D // Just a random, but recognizable value

// ALREADY_DONE_FOR_YOU: Defining 16-bit characteristic UUID
#define BLE_UUID_OUR_CHARACTERISTC_UUID          0xBEEF // Just a random, but recognizable value


typedef struct
{   
    uint16_t                    conn_handle; 
    uint16_t                    service_handle;  /**< Handle of Our Service (as provided by the BLE stack). */
     // Add handles for our characteristic
    ble_gatts_char_handles_t    char_handles;
     uint8_t uuid_type;
     uint8_t * p_char_value;

}ble_MyoWar_t;
//void MyoWar_init(ble_MyoWar_t * p_MyoWar);
//uint32_t our_sensor_characteristic_update(uint16_t conn_handle ,ble_MyoWar_t *p_MyoWar,int16_t sensor_value);