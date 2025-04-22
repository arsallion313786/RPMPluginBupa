package com.goqii.goqiiplugin;

import android.content.Context;
import android.util.Log;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import com.goqii.goqiisdk.GlucometerManager;

public class GoqiiPlugin extends CordovaPlugin {
    private static final String TAG = "GoqiiPlugin";
    private GlucometerManager glucometerManager;
    private CallbackContext lastCommandCallback;

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        Log.d(TAG, "execute: action = " + action);
        lastCommandCallback = callbackContext;
        if (action.equals("initializeSDK")) {
            initializeGlucometer();
            return true;
        } else if (action.equals("searchGlucometer")) {
            glucometerManager.startScan();
            return true;
        } else if (action.equals("unlinkGlucometer")) {
            glucometerManager.unpairDevice();
            return true;
        } else if (action.equals("syncGlucometer")) {
            glucometerManager.syncGlucometer();
            return true;
        } else if (action.equals("connectGlucometer")) {
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
                lastCommandCallback.success(result.toString());
                }catch(Exception e){
                    e.printStackTrace();
                }
            }

            @Override
            public void onDeviceUnlinked(String macId) {
                try{
                JSONObject result = new JSONObject();
                result.put("message", "Device Unlinked");
                lastCommandCallback.success(result.toString());
                }catch(Exception e){
                    e.printStackTrace();
                }
            }

            @Override
            public void onDeviceLinkFailed() {
                try{
                JSONObject result = new JSONObject();
                result.put("message", "Device Link Failed");
                lastCommandCallback.error(result.toString());
                }catch(Exception e){
                    e.printStackTrace();
                }
            }

            @Override
            public void onDeviceUnlinkFailed() {
                try{
                JSONObject result = new JSONObject();
                result.put("message", "Device Unlink Failed");
                    lastCommandCallback.error(result.toString());
                }catch(Exception e){
                    e.printStackTrace();
                }
            }

            @Override
            public void onSyncComplete(String data) {
                lastCommandCallback.success(data);
            }

            @Override
            public void deviceNotFound() {
              try{  
                JSONObject result = new JSONObject();
                result.put("message", "Device Not Found");
                lastCommandCallback.error(result.toString());
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
                lastCommandCallback.success(result.toString());
                }catch(Exception e){
                    e.printStackTrace();
                }
            }
        });
        try{
        JSONObject result = new JSONObject();
        result.put("message", "Glucometer Initialized Successfully");
        lastCommandCallback.success(result.toString());
        }catch(Exception e){
            e.printStackTrace();
        }
    }
}
