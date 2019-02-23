package mirrorshades;
import haxe.ds.Vector;
import haxe.Json;
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

@:autoBuild(mirrorshades.macro.Build.profileAll())
interface ProfileMethods{ }

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
    /**
     * Complete event duration. 
     */
    public var dur: UInt;
    /**
     * Instant event scope (g/p/t)
     */
    public var s: String;
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
    #if profile
    static var events:Array<Event> = [];
    #end

    static inline function getCurrentThreadId():Int{
        #if cpp
            return untyped __global__.__hxcpp_GetCurrentThreadNumber();
        #else
            return 0;
        #end
    }

    #if profile
    public static inline function sample(name:String, cat:String, ph:EventType, ts:UInt, pid:UInt, tid:UInt, ?args:Dynamic){
        var evt = new Event(name,cat,ph,ts,pid,tid,args);
        events.push(evt);
        return evt;
    }
    #end

    public static inline function begin(name, cat){
        #if profile
        sample(name, cat, EventType.DurationBegin, Time.now(), 0, getCurrentThreadId());
        #end
    }
    public static inline function end(name, cat){
        #if profile
        sample(name, cat, EventType.DurationEnd, Time.now(), 0, getCurrentThreadId());
        #end
    }
    public static inline function complete(name, cat, duration){
        #if profile
        sample(name, cat, EventType.Complete, Time.now(), 0, getCurrentThreadId()).dur = duration;
        #end
    }
    public static inline function instant(name, cat){
        #if profile
        sample(name, cat, EventType.Instant, Time.now(), 0, getCurrentThreadId()).s = 'g';
        #end
    }

    public static inline function count(name,cat,values:Dynamic){
        #if profile
        sample(name, cat, EventType.Counter, Time.now(), 0, getCurrentThreadId(), values);
        #end
    }

    public static inline function tick():UInt{
        #if profile
        return Time.now();
        #else
        return 0;
        #end
    }
    public static inline function tock(name, cat, startTime:UInt){
        #if profile
        complete(name, cat, Time.now()-startTime);
        #end
    }

    // End
    public static inline function flush(filePath:String){
        #if profile
        IO.dump(Json.stringify(events), filePath);
        events = [];
        #end
    }
}