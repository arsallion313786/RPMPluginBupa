package com.goqii.goqiiplugin;

import android.content.Context;
import android.util.Log;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import com.goqii.goqiisdk.GlucometerManager;

public class GoqiiPlugin extends CordovaPlugin {
    private static final String TAG = "GoqiiPlugin";
    private GlucometerManager glucometerManager;
    private CallbackContext lastCommandCallback;
    private CallbackContext resultListenerCallbackContext;

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        Log.d(TAG, "execute: action = " + action);
        lastCommandCallback = callbackContext;
        switch (action) {
            case "resultListener":
                resultListenerCallbackContext = callbackContext;
                return true;
            case "initializeSDK":
                initializeGlucometer();
                return true;
            case "searchGlucometer":
                glucometerManager.startScan();
                return true;
            case "unlinkGlucometer":
                glucometerManager.unpairDevice();

                return true;
            case "syncGlucometer":
                glucometerManager.syncGlucometer();
                return true;
            case "connectGlucometer":
                glucometerManager.linkDevice();
                return true;
        }
        return false;
    }

    /*
     * Initialize the Glucometer SDK
     */
    public void initializeGlucometer() {
        Context context = cordova.getActivity();
        glucometerManager = new GlucometerManager(context, new GlucometerManager.GlucometerListener() {
            @Override
            public void onDeviceLinked(String macId, String deviceName) {
                try{
                JSONObject result = new JSONObject();
                result.put("macId", macId);
                result.put("message", "Device Linked");
                result.put("name", deviceName);
                result.put("methodType", "connectGlucometer");
                // lastCommandCallback.success(result.toString());
                
                PluginResult pResult = new PluginResult(PluginResult.Status.OK, result.toString());
                pResult.setKeepCallback(true);
                    resultListenerCallbackContext.sendPluginResult(pResult);
                }catch(Exception e){
                    e.printStackTrace();
                }
            }

            @Override
            public void onDeviceUnlinked(String macId) {
                try{
                JSONObject result = new JSONObject();
                result.put("message", "Device Unlinked");
                // lastCommandCallback.success(result.toString());
                
                PluginResult pResult = new PluginResult(PluginResult.Status.OK, result.toString());
                pResult.setKeepCallback(true);
                    resultListenerCallbackContext.sendPluginResult(pResult);
                }catch(Exception e){
                    e.printStackTrace();
                }
            }

            @Override
            public void onDeviceLinkFailed() {
                try{
                JSONObject result = new JSONObject();
                result.put("message", "Device Link Failed");
                // lastCommandCallback.error(result.toString());
                
                PluginResult pResult = new PluginResult(PluginResult.Status.ERROR, "Device Link Failed");
                pResult.setKeepCallback(true);
                    resultListenerCallbackContext.sendPluginResult(pResult);
                }catch(Exception e){
                    e.printStackTrace();
                }
            }

            @Override
            public void onDeviceUnlinkFailed() {
                try{
                JSONObject result = new JSONObject();
                result.put("message", "Device Unlink Failed");
                // lastCommandCallback.error(result.toString());
                
                PluginResult pResult = new PluginResult(PluginResult.Status.ERROR, "Device Unlink Failed");
                pResult.setKeepCallback(true);
                    resultListenerCallbackContext.sendPluginResult(pResult);
                }catch(Exception e){
                    e.printStackTrace();
                }
            }

            @Override
            public void onSyncComplete(String result) {
                // lastCommandCallback.success(data);

                PluginResult pResult = new PluginResult(PluginResult.Status.OK, result);
                pResult.setKeepCallback(true);
                resultListenerCallbackContext.sendPluginResult(pResult);
            }

            @Override
            public void deviceNotFound() {
              try{  
                JSONObject result = new JSONObject();
                result.put("message", "Device Not Found");
                // lastCommandCallback.error(result.toString());
                PluginResult pResult = new PluginResult(PluginResult.Status.ERROR, "Device not found");
                pResult.setKeepCallback(true);
                  resultListenerCallbackContext.sendPluginResult(pResult);
                }catch(Exception e){
                    e.printStackTrace();
                }
            }

            @Override
            public void onDeviceFound(String macId, String deviceName) {
                try{
                JSONObject result = new JSONObject();
                result.put("macId", macId);
                result.put("name", deviceName);
                result.put("message", "Device Found");
                result.put("methodType","searchGlucometer");
                // lastCommandCallback.success(result.toString());
    
                PluginResult pResult = new PluginResult(PluginResult.Status.OK, result);
                pResult.setKeepCallback(true);
                    resultListenerCallbackContext.sendPluginResult(pResult);

                }catch(Exception e){
                    e.printStackTrace();
                }
            }
        });
        try{
        JSONObject result = new JSONObject();
        result.put("message", "Glucometer Initialized Successfully");
        result.put("methodType", "initializeSDK");

        // lastCommandCallback.success(result.toString());

        PluginResult pResult = new PluginResult(PluginResult.Status.OK, result);
        pResult.setKeepCallback(true);
        resultListenerCallbackContext.sendPluginResult(pResult);
        }catch(Exception e){
            e.printStackTrace();
        }
    }
}
