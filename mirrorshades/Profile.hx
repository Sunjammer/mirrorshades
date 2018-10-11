package mirrorshades;
import haxe.ds.Vector;
import haxe.Json;
import cpp.vm.Thread;
import mirrorshades.platform.*;

/*
{
  "name": "myName",
  "cat": "category,list",
  "ph": "B",
  "ts": 12345,
  "pid": 123,
  "tid": 456,
  "args": {
    "someArg": 1,
    "anotherArg": {
      "value": "my value"
    }
  }
}

*/

@:enum abstract EventType(String){
    var DurationBegin = "B";
    var DurationEnd = "E";
    var AsyncDurationBegin = "b";
    var AsyncDurationEnd = "e";
    var AsyncInstant = "n";
    var FlowStart = "s";
    var FlowStep = "t";
    var FlowEnd = "f";
    var Sample = "P";
    var ObjectCreated = "N";
    var ObjectSnapshot = "O";
    var ObjectDestroyed = "D";
    var Metadata = "M";
    var MemoryDumpGlobal = "V";
    var MemoryDumpProcess = "v";
    var Mark = "R";
    var Complete = "X";
    var Instant = "i";
    var Counter = "C";
    var ClockSync = "c";
}

class Event{
    /**
     * The name of the event, as displayed in Trace Viewer
     */
    public var name: String; 
    /**
     * The event categories. This is a comma separated list of categories for the event. The categories can be used to hide events in the Trace Viewer UI.
     */
    public var cat: String;
    /**
     * The event type. This is a single character which changes depending on the type of event being output. 
     * The valid values are listed in the table below. We will discuss each phase type below.
     */
    public var ph: EventType;
    /**
     * The tracing clock timestamp of the event. The timestamps are provided at microsecond granularity.
     */
    public var ts: UInt;
    /**
     * The process ID for the process that output this event.
     */
    public var pid: UInt;
    /**
     * The thread ID for the thread that output this event.
     */
    public var tid: UInt;
    /**
     * Any arguments provided for the event. 
     * Some of the event types have required argument fields, otherwise, you can put any information you wish in here. 
     * The arguments are displayed in Trace Viewer when you view an event in the analysis section.
     */
    public var args: Dynamic;
    public inline function new(name, cat, ph, ts, pid, tid, ?args){
        this.name = name;
        this.cat = cat;
        this.ph = ph;
        this.ts = ts;
        this.pid = pid;
        this.tid = tid;
        this.args = args;
    }
    public inline function serialize():String{
        return Json.stringify(this);
    }
}

class Profile {
    static var events:Array<Event> = [];
    static var sampling:Bool = false;

    static inline function getCurrentThreadId():Int{
        #if cpp
            return untyped __global__.__hxcpp_GetCurrentThreadNumber();
        #else
            return 0;
        #end
    }

    public static inline function sample(name:String, cat:String, ph:EventType, ts:UInt, pid:UInt, tid:UInt, ?args:Dynamic){
        if(sampling)
            events.push(new Event(name,cat,ph,ts,pid,tid,args));
    }

    public static inline function begin(name, cat){
        sample(name, cat, EventType.DurationBegin, Time.now(), 0, getCurrentThreadId());
    }
    public static inline function end(name, cat){
        sample(name, cat, EventType.DurationEnd, Time.now(), 0, getCurrentThreadId());
    }


    // Duration events
    public static inline function start(){
        sampling = true;
    }

    // End
    public static inline function stop(filePath:String){
        IO.dump(Json.stringify(events), filePath);
        events = [];
        sampling = false;
    }
}