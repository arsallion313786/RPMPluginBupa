package com.goqii.goqiiplugin;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.LOG;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.content.Context;

import net.huray.omronsdk.ble.entity.DiscoveredDevice;
import net.huray.omronsdk.ble.entity.SessionData;
import net.huray.omronsdk.ble.enumerate.OHQCompletionReason;
import net.huray.omronsdk.ble.enumerate.OHQConnectionState;
import com.goqii.goqiisdk.OmronDeviceWrapper;

import java.util.ArrayList;
import java.util.List;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.JsonArray;

public class OmronDevicePlugin extends CordovaPlugin implements OmronDeviceWrapper.OmronDeviceCallback {

    private OmronDeviceWrapper omronDeviceWrapper;
    //private CallbackContext scanCallbackContext;
    //private CallbackContext connectionCallbackContext;
    private CallbackContext resultListenerCallbackContext;


    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        switch (action) {
            case "resultListener":
            this.resultListenerCallbackContext = callbackContext;
            return true;
            case "initialize":
                initialize(callbackContext);
                return true;

            case "startScanning":
                if (omronDeviceWrapper == null) {
                    callbackContext.error("Plugin is not initialized. Call initialize() first.");
                    return false;
                }
                //this.scanCallbackContext = callbackContext;
                omronDeviceWrapper.startScanning();
                return true;

            case "connectAndSync":
                if (omronDeviceWrapper == null) {
                    callbackContext.error("Plugin is not initialized. Call initialize() first.");
                    return false;
                }
                //this.connectionCallbackContext = callbackContext;
                omronDeviceWrapper.connectAndSync();
                return true;

            case "disconnect":
                if (omronDeviceWrapper != null) {
                    omronDeviceWrapper.disconnect();
                    callbackContext.success("Device disconnected successfully");
                } else {
                    callbackContext.error("Plugin is not initialized. Call initialize() first.");
                }
                return true;

            case "unlink":
                if (omronDeviceWrapper != null) {
                    omronDeviceWrapper.unpairDevice();
                    callbackContext.success("Device Unlinked successfully");
                } else {
                    callbackContext.error("Plugin is not initialized. Call initialize() first.");
                }
                return true;

            default:
                return false;
        }
    }

    private void initialize(CallbackContext callbackContext) {
        Context context = cordova.getActivity().getApplicationContext();
        omronDeviceWrapper = new OmronDeviceWrapper(context, this);
        JSONObject resultObj = new JSONObject();
        try {
            resultObj.put("status", "initialized successfully");
            resultObj.put("methodType", "initialize_method_bupa");
            PluginResult result = new PluginResult(PluginResult.Status.OK, resultObj.toString());
            result.setKeepCallback(true);
            resultListenerCallbackContext.sendPluginResult(result);
        }
        catch (JSONException e) {
            e.printStackTrace();
        }
       
      

        //resultListenerCallbackContext.success("OmronDeviceWrapper initialized successfully");
    }

    @Override
    public void onScanResult(List<DiscoveredDevice> discoveredDevices) {
        JSONArray resultArray = new JSONArray();
        for (DiscoveredDevice device : discoveredDevices) {
            JSONObject deviceObj = new JSONObject();
            try {
                deviceObj.put("macId", device.getAddress());
                //deviceObj.put("methodType", "initialize_method_bupa");
                resultArray.put(deviceObj);
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        PluginResult result = new PluginResult(PluginResult.Status.OK, resultArray.toString());
        result.setKeepCallback(true);
        resultListenerCallbackContext.sendPluginResult(result);
    }

    @Override
    public void onScanCompleted(OHQCompletionReason reason) {
       
        JSONObject resultObj = new JSONObject();
        try{
            resultObj.put("status","scan completed" + " " + reason.name());
        resultObj.put("methodType","startScanning_method_bupa");
        PluginResult result = new PluginResult(PluginResult.Status.OK, resultObj.toString());
        result.setKeepCallback(true);
        resultListenerCallbackContext.sendPluginResult(result); 
        }
        catch (JSONException e) {
            e.printStackTrace();
        }
        
        // scanCallbackContext.success("Scan completed: " + reason.name());
    }

    @Override
    public void onConnected(String macId) {
        try {
            JSONObject resultObj = new JSONObject();
            resultObj.put("macId", macId);
            resultObj.put("name", "Omron Blood Pressure Monitor");
            resultObj.put("message", "Device connected");
            resultObj.put("methodType", "connectAndSync_method_bupa");
            PluginResult result = new PluginResult(PluginResult.Status.OK, resultObj.toString());
            result.setKeepCallback(true);
            resultListenerCallbackContext.sendPluginResult(result);    
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onDisconnected() {
        // try {
        //     JSONObject resultObj = new JSONObject();
        //     resultObj.put("message", "Device disconnected");
        //     PluginResult result = new PluginResult(PluginResult.Status.OK, resultObj.toString());
        //     result.setKeepCallback(true);
        //     connectionCallbackContext.sendPluginResult(result);
        // } catch (JSONException e) {
        //     e.printStackTrace();
        // }
    }

    @Override
    public void onDataSynced(SessionData sessionData) {
        JSONObject dataObj = new JSONObject();
        try {
            // dataObj.put("deviceCategory", sessionData.getDeviceCategory().name());
            // dataObj.put("modelName", sessionData.getModelName());
            // dataObj.put("currentTime", sessionData.getCurrentTime());
            // dataObj.put("batteryLevel", sessionData.getBatteryLevel());
            LOG.d("cordova sync", sessionData.toString());  
            JSONArray measurementRecords = new JSONArray();
            Gson gson = new Gson();
            String jsonString = gson.toJson(sessionData);
            JSONObject jsonObject = new JSONObject(jsonString);
            JSONArray measurementRecordsArray = jsonObject.optJSONArray("measurementRecords");

            if (measurementRecordsArray != null) {
                // measurementRecordsArray.forEach(record -> {
                //     JSONObject recordObj = new JSONObject();
                //     try {
                //         recordObj.put("Timestamp", jsonObject.get("TimeStampKey"));
                //         recordObj.put("Systolic", jsonObject.get("SystolicKey"));
                //         recordObj.put("Diastolic", jsonObject.get("DiastolicKey"));
                //         recordObj.put("PulseRate", jsonObject.get("PulseRateKey"));
                //         recordObj.put("Unit", jsonObject.get("BloodPressureUnitKey"));
                //         recordObj.put("UserID", jsonObject.get("UserIndexKey"));
                //         recordObj.put("MeanArterialPressure", jsonObject.get("MeanArterialPressureKey"));
                //         measurementRecords.put(recordObj);
                //     } catch (JSONException e) {
                //         e.printStackTrace();
                //     }
                // });

                for (int i = 0; i < measurementRecordsArray.length(); i++) {
                    JSONObject record = measurementRecordsArray.getJSONObject(i);

                    JSONObject parsedRecord = new JSONObject();
                    parsedRecord.put("Unit", record.optString("BloodPressureUnitKey"));
                    parsedRecord.put("Systolic", record.optDouble("SystolicKey"));
                    parsedRecord.put("PulseRate", record.optDouble("PulseRateKey"));
                    parsedRecord.put("Diastolic", record.optDouble("DiastolicKey"));
                    parsedRecord.put("UserID", record.optInt("UserIndexKey"));
                    parsedRecord.put("MeanArterialPressure", record.optDouble("MeanArterialPressureKey"));
                    parsedRecord.put("Timestamp", record.optString("TimeStampKey"));
                    parsedRecord.put("methodType", "connectAndSync_method_bupa");
                    measurementRecords.put(parsedRecord);
                }
            }

            dataObj.put("data", measurementRecords);

            PluginResult result = new PluginResult(PluginResult.Status.OK, dataObj.toString());
            result.setKeepCallback(true);
            resultListenerCallbackContext.sendPluginResult(result);
        } catch (JSONException e) {
            e.printStackTrace();
            JSONObject data = new JSONObject();
            try {
                data.put("message", "Error parsing session data");
            } catch (JSONException jsonException) {
                jsonException.printStackTrace();
            }
            PluginResult errorResult = new PluginResult(PluginResult.Status.ERROR, data.toString());
            errorResult.setKeepCallback(true);
            resultListenerCallbackContext.sendPluginResult(errorResult);
        }
    }

    @Override
    public void onError(String error) {
        resultListenerCallbackContext.error(error);
    }

    @Override
    public void onConnectionStateChanged(OHQConnectionState state) {
        // PluginResult result = new PluginResult(PluginResult.Status.OK, "Connection state changed: " + state.name());
        // result.setKeepCallback(true);
        // connectionCallbackContext.sendPluginResult(result);
    }
}
