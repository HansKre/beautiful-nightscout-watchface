import Toybox.System;

(:background)
class RequestBackground extends Toybox.System.ServiceDelegate {

    function initialize() {
        System.ServiceDelegate.initialize();
    }

    function onTemporalEvent() {
        controller.makeNightscoutRequest();
    }

}
