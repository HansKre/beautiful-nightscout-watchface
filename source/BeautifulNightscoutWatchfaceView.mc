import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class BeautifulNightscoutWatchfaceView extends WatchUi.WatchFace {

    var isAwake;

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        isAwake = true;
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Get the current time and format it correctly
        var timeFormat = isAwake ? "$1$:$2$:$3$" : "$1$:$2$";
        var clockTime = System.getClockTime();

        var hours = clockTime.hour;
        if (!System.getDeviceSettings().is24Hour) {
            if (hours > 12) {
                hours = hours - 12;
            }
        } else {
            if (getApp().getProperty("UseMilitaryFormat")) {
                timeFormat = isAwake ? "$1$$2$$3$" : "$1$$2$";
                hours = hours.format("%02d");
            }
        }

        var timeString = Lang.format(
                timeFormat,
                [hours, clockTime.min.format("%02d"), clockTime.sec.format("%02d")]
            );

        // Update the view
        var timeLabel = View.findDrawableById("TimeLabel") as Text;
        timeLabel.setColor(getApp().getProperty("ForegroundColor") as Number);
        timeLabel.setText(timeString);

        var bgLabel = View.findDrawableById("GlucoseLevel") as Text;
        bgLabel.setColor(getApp().getProperty("ForegroundColor") as Number);
        if (controller.getState().hasKey("bg")) {
            var bgVal = controller.getState()["bg"] as Number;
            if (bgVal) {
                bgLabel.setText(bgVal.toString());
            }
        }

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
        isAwake = true;
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
        isAwake = false;
    }

}
