import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.UserProfile as User;
using Toybox.Application.Properties as Props;

const BOERNIE_CONST = 3.375f;
const WINDOW_SIZE = 3;

class BoernieMeterView extends WatchUi.DataField{
    hidden var userWeight as Float;

    hidden var curBoernie as Float;

    hidden var avgBoernie3s as Float = 0.0;
    hidden var valWindow = new Array<Float>[WINDOW_SIZE];
    hidden var windowIdx as Number = 0;

    hidden var aboveCnt as Number;
    hidden var belowCnt as Number;
    hidden var alarmRaised as Boolean;

    hidden var info;

    function initialize() {
        DataField.initialize();
        me.curBoernie = 0.0f;
        me.aboveCnt = 0;
        me.belowCnt = 0;
        me.info = Rez.Strings.AppName;
        me.alarmRaised = false;

        var idx = 0;
        while (idx < me.valWindow.size()){
            me.valWindow[idx] = 0.0f;
            idx +=1;
        }

        // User weight in kg
        me.userWeight = (User.getProfile().weight as Float)/1000.0;
        if (me.userWeight == null){
            System.println("no user weight defined");
            me.info = Rez.Strings.noUsrWeight;
            me.userWeight = 1.0f;
        }
    }


    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc as Dc) as Void {
        //System.println("on_layout " + dc.getWidth() + " x " + dc.getHeight() );
        if(dc.getWidth() > 145 ){
            if (dc.getHeight() > 65){
                View.setLayout(Rez.Layouts.FullLayout(dc));
            }
            else {
                View.setLayout(Rez.Layouts.SlimLayout(dc));
            }
        } else{
            View.setLayout(Rez.Layouts.HalfLayout(dc));
        }

        //var labelView = View.findDrawableById("unit_label") as Text;
        // labelView.locY = labelView.locY - 16;
        // var valueView = View.findDrawableById("value") as Text;
        // var infoView = View.findDrawableById("info") as Text;
        // infoView.locY = valueView.locY + 45;
        //(View.findDrawableById("unitLabel") as Text).setText(Rez.Strings.unit_label);
    }


    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info as Activity.Info) as Void {
        if(! (info has :currentPower) ){
            System.println("Need a Powermeter!");
            me.info = Rez.Strings.noPwrMeter;
            return;
        }

        if(info.currentPower != null){
            var pwr = info.currentPower as Float;
            pwr = pwr / me.userWeight;
            me.curBoernie = pwr / BOERNIE_CONST;
            
            me.windowIdx = updateWindow(me.curBoernie, me.windowIdx, me.valWindow);
            me.avgBoernie3s = arrayMean(me.valWindow);
        }
        updateCounters();
    }


    function updateWindow(val as Float, index as Number, window as Array<Float>){
        window[index] = val;
        return (index + 1)% WINDOW_SIZE;
    }


    function arrayMean(arr as Array<Number>){
        var i = 1;
        var sum = arr[0];
        while(i < arr.size()){
            sum += arr[i];
            i++;
        }
        return sum/arr.size();
    }

    function alarm(alm as Boolean){
        if(alm){
            if (!alarmRaised){
                alarmRaised = true;
                me.info = Rez.Strings.almBoernieThresholdExceeded;
                if (Attention has :ToneProfile) {
                    var toneProfile =
                    [
                        new Attention.ToneProfile( 2500, 250),
                        new Attention.ToneProfile( 5000, 450),
                        new Attention.ToneProfile( 2500, 250)
                    ];
                    Attention.playTone({:toneProfile=>toneProfile});
                }
            }
        } else{
            me.info = "";
            alarmRaised = false;
        }
    }

    function updateCounters(){
        if(me.curBoernie > Props.getValue("hThres")){
            aboveCnt += 1;
            belowCnt = 0;
            if(aboveCnt >= Props.getValue("hysteresisCnt")){
                alarm(true);
            }
        }
        if (me.curBoernie < Props.getValue("lThres")){
            belowCnt += 1;
            aboveCnt = 0;
            if(belowCnt >= Props.getValue("hysteresisCnt")){
                alarm(false);
            }
        }
    }


    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc as Dc) as Void {
        // Set the background color
        (View.findDrawableById("Background") as Text).setColor(getBackgroundColor());

        // Determine Color for value and info
        var foregroundColor = (getBackgroundColor() == Graphics.COLOR_BLACK) ?
            Graphics.COLOR_WHITE : Graphics.COLOR_BLACK;
        foregroundColor = (me.alarmRaised) ?
            Graphics.COLOR_RED : foregroundColor;

        // Set the foreground color and value
        var value = View.findDrawableById("value") as Text;
        value.setColor(foregroundColor);
        value.setText(me.avgBoernie3s.format("%.2f"));

        // Update info text
        var infolabel = View.findDrawableById("info") as Text;
        if(infolabel != null && dc.getHeight() > 100){
            infolabel.setText(me.info);
            infolabel.setColor(foregroundColor);
        }
        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
    }

}
