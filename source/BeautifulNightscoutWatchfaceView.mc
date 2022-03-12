import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.ActivityMonitor;
import Toybox.Time.Gregorian;

class BeautifulNightscoutWatchfaceView extends WatchUi.WatchFace {

    var isAwake;

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MyWatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        isAwake = true;
    }

    function getTimeStr() as String {
        var canUpdateEverySecond = ( Toybox.WatchUi.WatchFace has :onPartialUpdate );
        var showSeconds = canUpdateEverySecond || isAwake;

        // Get the current time and format it correctly
        var timeFormat = showSeconds ? "$1$:$2$:$3$" : "$1$:$2$";
        var clockTime = System.getClockTime();

        var hours = clockTime.hour;
        if (!System.getDeviceSettings().is24Hour) {
            if (hours > 12) {
                hours = hours - 12;
            }
        } else {
            if (getApp().getProperty("UseMilitaryFormat")) {
                timeFormat = showSeconds ? "$1$$2$$3$" : "$1$$2$";
                hours = hours.format("%02d");
            }
        }

        var timeString = Lang.format(
                timeFormat,
                [hours, clockTime.min.format("%02d"), clockTime.sec.format("%02d")]
            );

        return timeString;
    }

    function drawTime(dc as Dc, timeString as String) as Void {
        var timeLabel = View.findDrawableById("Time") as Text;
        timeLabel.setColor(getApp().getProperty("ForegroundColor") as Number);
        timeLabel.setText(timeString);
    }

    function drawGlucose(dc as Dc) as Void {
        var glucoseLabel = View.findDrawableById("GlucoseLevel") as Text;
        glucoseLabel.setColor(getApp().getProperty("ForegroundColor") as Number);
        if (controller.getState().hasKey("bg")) {
            var bgVal = controller.getState()["bg"] as Number;
            if (bgVal) {
                glucoseLabel.setText(bgVal.toString());
            }
        }
    }

    function drawBattery(dc as Dc) as Void {
        var batteryVal = System.getSystemStats().battery;
        // round up to avoid 99.9999 for full battery
        batteryVal = batteryVal + .5;
        // format as 2-digits and suffixed with %
        var batStr = Lang.format( "$1$%", [ batteryVal.format( "%2d" ) ] );
        var batteryLabel = View.findDrawableById("Battery");
        batteryLabel.setColor(getApp().getProperty("ForegroundColor") as Number);
        batteryLabel.setText(batStr);
    }

    function drawSteps(dc as Dc) as Void {
        var steps = ActivityMonitor.getInfo().steps;
        var stepsLabel = View.findDrawableById("Steps");
        stepsLabel.setColor(getApp().getProperty("ForegroundColor") as Number);
        stepsLabel.setText(steps.toString());
    }

    function drawDate(dc as Dc) as Void {
        var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var dateStr = Lang.format(
            "$1$.$2$.$3$",
            [
                today.day < 10 ? "0" + today.day : today.day,
                today.month < 10 ? "0" + today.month : today.month,
                today.year
            ]
        );

        var dateLabel = View.findDrawableById("Date") as Text;
        dateLabel.setColor(getApp().getProperty("ForegroundColor") as Number);
        dateLabel.setText(dateStr);
    }

    function drawLine(dc, lineColor) {
        var textDimensions = dc.getTextDimensions(getTimeStr(), Graphics.FONT_SYSTEM_NUMBER_MEDIUM) as Lang.Array<Lang.Number>;
        var width = textDimensions[0];
        var height = textDimensions[1];

        // x
        var freeSpace = dc.getWidth() - width;
        var x = freeSpace / 2;

        // y
        var timeOffset = 0.5;
        var y = dc.getHeight() * timeOffset;

        // draw
        var background = getApp().getProperty("BackgroundColor") as Number;
        dc.setColor(lineColor, background);
        dc.fillRectangle(x, y, width, 5);
    }

    // for debugging
    function drawClippingArea(dc) {
        var textDimensions = dc.getTextDimensions(getTimeStr(), Graphics.FONT_SYSTEM_NUMBER_MEDIUM) as Lang.Array<Lang.Number>;
        var width = textDimensions[0];
        var height = textDimensions[1];

        // x
        var freeSpace = dc.getWidth() - width;
        var x = freeSpace / 2;

        // y
        var timeOffset = 0.5;
        var y = dc.getHeight() * timeOffset;

        var lineColor = Graphics.COLOR_BLUE;
        var background = getApp().getProperty("BackgroundColor") as Number;
        dc.setColor(lineColor, background);
        var WIDTH_REDUCTION = 1;
        var HEIGHT_REDUCTION = 0.6;
        var SHIFT_RIGHT = 2;
        var SHIFT_DOWN = 15;
        dc.drawRectangle(
            x + SHIFT_RIGHT,
            y + SHIFT_DOWN,
            width * WIDTH_REDUCTION,
            height * HEIGHT_REDUCTION
          );
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        // draw
        drawSteps(dc);
        drawGlucose(dc);
        drawTime(dc, getTimeStr());
        drawDate(dc);
        drawBattery(dc);

        drawLine(dc, Graphics.COLOR_BLUE);

        //drawClippingArea(dc);
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

    //! onPartialUpdate() is called each second as long as the device
    //! power budget is not exceeded.
    //! It is important to update as small of a portion of the display as possible
    //! in this method to avoid exceeding the allowed power budget. To do this, the
    //! application must set the clipping region for the Graphics.Dc object using
    //! the setClip method. Calls to Toybox.System.println() and Toybox.System.print()
    //! will not execute on devices when this function is being invoked, but can be
    //! used in the device simulator.
    //! @param [Graphics.Dc] dc The drawing context
    //! @since 2.3.0
    //! https://developer.garmin.com/connect-iq/connect-iq-faq/how-do-i-get-my-watch-face-to-update-every-second/
    //! to test in simulator: Settings > Low Power Mode
    function onPartialUpdate(dc) {
        View.onUpdate(dc);

        var timeString = getTimeStr();

        var textDimensions = dc.getTextDimensions(timeString, Graphics.FONT_SYSTEM_NUMBER_MEDIUM) as Lang.Array<Lang.Number>;
        var width = textDimensions[0];
        var height = textDimensions[1];

        // x
        var freeSpace = dc.getWidth() - width;
        var x = freeSpace / 2;

        // y
        var timeOffset = 0.5;
        var y = dc.getHeight() * timeOffset;

        var lineColor = Graphics.COLOR_BLUE;
        var background = getApp().getProperty("BackgroundColor") as Number;
        dc.setColor(lineColor, background);
        var WIDTH_REDUCTION = 1;
        var HEIGHT_REDUCTION = 0.6;
        var SHIFT_RIGHT = 2;
        var SHIFT_DOWN = 15;
        /*dc.drawRectangle(
            x + SHIFT_RIGHT,
            y + SHIFT_DOWN,
            width * WIDTH_REDUCTION,
            height * HEIGHT_REDUCTION
         );*/

        drawTime(dc, timeString);

        // set the area to update partially
        dc.setClip(
            x + SHIFT_RIGHT,
            y + SHIFT_DOWN,
            width * WIDTH_REDUCTION,
            height * HEIGHT_REDUCTION
        );

    }

}
