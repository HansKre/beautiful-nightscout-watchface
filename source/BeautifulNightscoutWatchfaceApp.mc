import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import State;

// global Controller to manage state
var controller;

// global getApp() helper
(:background)
function getApp() as BeautifulNightscoutWatchfaceApp {
    return Application.getApp() as BeautifulNightscoutWatchfaceApp;
}

(:background)
class BeautifulNightscoutWatchfaceApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
        controller = new State.Controller();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
        controller.unregisterBackgroundEvent();
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        controller.validateAndUpdateUrl();
        controller.registerBackgroundEvent();
        return [ new BeautifulNightscoutWatchfaceView() ] as Array<Views or InputDelegates>;
    }

    // New app settings have been received so trigger a UI update
    function onSettingsChanged() as Void {
        controller.validateAndUpdateUrl();
        WatchUi.requestUpdate();
    }

    // This function is called when the temporal event occurrs
    function getServiceDelegate(){
        controller.setBackground(true);
        return [ new RequestBackground() ] as Array<ServiceDelegate>;
    }

    // This function passes data back to the main process when
    // BG process has exited
    function onBackgroundData(data) {
        controller.onBackgroundData(data);
    }

}
