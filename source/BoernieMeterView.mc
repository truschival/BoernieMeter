import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.UserProfile as User;

const BOERNIE_CONST = 3.375f;
const CNT_HYSTERESIS = 5;
const UPPER_THRES = 1.1;
const LOWER_THRES = 0.95;

class BoernieMeterView extends WatchUi.DataField{
    hidden var curBoernie as Float;
    hidden var userWeight as Float;

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
        View.setLayout(Rez.Layouts.MainLayout(dc));
        //var labelView = View.findDrawableById("unit_label") as Text;
        // labelView.locY = labelView.locY - 16;
        var valueView = View.findDrawableById("value") as Text;
        var infoView = View.findDrawableById("info") as Text;
        infoView.locY = valueView.locY + 35;
        (View.findDrawableById("unit_label") as Text).setText(Rez.Strings.unit_label);
    }


    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info as Activity.Info) as Void {

        if(! (info has :currentPower) ){    System.println("Need a Powermeter!");
            me.info = Rez.Strings.noPwrMeter;
                    return;
        }
        
        if(info.currentPower != null){
            var pwr = info.currentPower as Float;
            pwr = pwr / me.userWeight;
            me.curBoernie = pwr / BOERNIE_CONST;
        }
        
        updateCounters();
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
                        new Attention.ToneProfile( 5000, 350),
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
        if(me.curBoernie > UPPER_THRES){
            aboveCnt += 1;
            belowCnt = 0;
            if(aboveCnt >= CNT_HYSTERESIS){
                alarm(true);
            }
        }
        if (me.curBoernie < LOWER_THRES){
            belowCnt += 1;
            aboveCnt = 0;
            if(belowCnt >= CNT_HYSTERESIS){
                alarm(false);
            }
        }
    }


    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc as Dc) as Void {
        // Set the background color
        (View.findDrawableById("Background") as Text).setColor(getBackgroundColor());

        var infolabel = View.findDrawableById("info") as Text;
        infolabel.setText(me.info);

        // Set the foreground color and value
        var value = View.findDrawableById("value") as Text;
        var foregroundColor = (getBackgroundColor() == Graphics.COLOR_BLACK) ? Graphics.COLOR_WHITE : Graphics.COLOR_BLACK;
   
        if (me.alarmRaised){
            value.setColor(Graphics.COLOR_RED);
            infolabel.setColor(Graphics.COLOR_RED);
        }else{
            value.setColor(foregroundColor);
            infolabel.setColor(foregroundColor);
        }

        value.setText(me.curBoernie.format("%.2f"));
        System.println(" update " + me.curBoernie.format("%.2f"));
        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
    }

}
