using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.Background;
using Toybox.Time;
using Toybox.Time.Gregorian as Calendar;

module State {
    class Controller {
        private var STATE = "appstate";
        private var inBackground=false;

        function initState() {
            getState();
        }

        function initialize() {
            initState();
        }

        function getState() {
            var _state = {};
            try {
                _state = getApp().getProperty(STATE);
                if (_state == null || _state == {}) {
                    _state = {};
                    _state["str"] = "";
                    _state["bg"] = 0;
                    _state["direction"] = "";
                    _state["mills"] = 0;
                    _state["delta"] = 0;
                    _state["resCode"] = 0;
                    setState(_state);
                }
            } catch (exception) {
                Sys.println(exception);
            } finally {
                return _state;
            }
        }

        function setState(data) {
            getApp().setProperty(STATE, data);
        }

        function getUrl() {
            return getApp().getProperty("NightScoutUrl") as String;
        }

        function getUnit() {
            return getApp().getProperty("Unit");
        }

        function validateAndUpdateUrl() {
            var currentUrl = getUrl();
            Sys.println("Current URL: " + currentUrl);
            if (currentUrl != null && !currentUrl.equals("")) {
                var newUrl = currentUrl.toString();

                if (newUrl.find("https://") == null && newUrl.find("http://") == null ) {
                    newUrl = "https://" + newUrl;
                }

                if ( newUrl.find("http://") != null ) {
                    newUrl = "https://" + newUrl.substring(7, newUrl.length());
                }

                // remove trailing "/"
                var lastChar = newUrl.substring(newUrl.length()-1, newUrl.length());
                if (lastChar.equals("/")) {
                    newUrl = newUrl.substring(0, newUrl.length()-1);
                }

                if (currentUrl != newUrl) {
                    System.println("New URL: " + newUrl);
                    getApp().setProperty("NightScoutUrl", newUrl);
                }
            }
        }

        function registerBackgroundEvent() {
            var url = getUrl();

            if(!(Toybox.System has :ServiceDelegate)) {
                Sys.println("Background not availabe");
                return;
            }

            if ((url == null) || url.equals("")) {
                Sys.println("Invalid URL");
                return;
            }

            Background.registerForTemporalEvent(new Time.Duration(5 * 60));
        }

        (:background)
        function unregisterBackgroundEvent() {
            if(!inBackground) {
                Background.deleteTemporalEvent();
            }
        }

        function setBackground(_inBackground) {
            inBackground = _inBackground;
        }

        function onBackgroundData(data) {
            if (data != null) {
                setState(data);
            }
        }

        function makeNightscoutRequest() {
            var baseUrl = getUrl();
            var apiPath = "/api/v2/properties/bgnow,rawbg,delta";
            var url = baseUrl + apiPath;
            System.println("Making request to: " + url);
            var parameters = {
                "format" => "json"
            };
            var options = {};
            var responseCallback = method(:processResponse);

            Communications.makeWebRequest(
                url,
                parameters,
                options,
                responseCallback
            );
        }

        function processResponse(responseCode, data) {
            var glucoseData = {};
            var bg = 0;
            var bg_mgdl = 0;
            var direction = "";
            var delta = "";
            var mills = 0l;
            var resCode = responseCode;

            if (responseCode != 200) {
                Sys.println("HTTP Request Error with Response Code: " + responseCode);
                glucoseData["resCode"] = responseCode;
            }

            if (responseCode == 200) {
                Sys.println(data.toString());
                // set BG
                if (data.hasKey("bgnow") && data["bgnow"].hasKey("sgvs") && data["bgnow"]["sgvs"][0].hasKey("scaled")) {
                    bg = data["bgnow"]["sgvs"][0]["scaled"];
                }

                // set bg_mgdl
                if (data.hasKey("bgnow") && data["bgnow"].hasKey("sgvs") && data["bgnow"]["sgvs"][0].hasKey("mgdl")) {
                    bg_mgdl = data["bgnow"]["sgvs"][0]["mgdl"];
                }

                // set elapsed time
                if (data.hasKey("bgnow") && data["bgnow"].hasKey("mills")) {
                    mills = data["bgnow"]["mills"];
                }

                // set direction
                if (data.hasKey("bgnow") && data["bgnow"].hasKey("sgvs") && data["bgnow"]["sgvs"][0].hasKey("direction")) {
                    direction = data["bgnow"]["sgvs"][0]["direction"];
                }

                // set delta
                if (data.hasKey("delta") && data["delta"].hasKey("display")) {
                    delta = data["delta"]["display"].toString();
                }

                glucoseData["str"] = bg.toString() + " " + direction + " " + delta;
                glucoseData["bg"] = bg;
                glucoseData["bg_mgdl"] = bg_mgdl;
                glucoseData["direction"] = direction;
                glucoseData["mills"] = mills;
                glucoseData["delta"] = delta;
                glucoseData["resCode"] = responseCode;
            }

            Background.exit(glucoseData);
        }
    }
 }