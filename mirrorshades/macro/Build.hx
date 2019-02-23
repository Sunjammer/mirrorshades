package mirrorshades.macro;
import haxe.macro.*;
import haxe.macro.Expr;

class Build{
    #if macro
    public static function profileAll(){
        var fields = Context.getBuildFields();
        var cl = Context.getLocalClass().get();
        var classname = cl.pack.concat([cl.name]).join(".");
        for(f in fields){
            switch(f){
                case { kind: FFun({expr:expr}), name:name }:
                
                switch(expr.expr){
                    case EBlock(exprs):
                        trace("Profile: "+classname+": "+name+": "+exprs);
                        var newExprs = exprs.concat([]);
                        var key = classname+":"+name;
                        var begin = Context.parse("mirrorshades.Profile.begin('"+key+"', 'Performance')", Context.currentPos());
                        var end = Context.parse("mirrorshades.Profile.end('"+key+"', 'Performance')", Context.currentPos());
                        var newExprs = [begin].concat(exprs).concat([end]);
                        switch(newExprs[newExprs.length-2]){
                            case { expr: EReturn(_) }:
                            var tmp = newExprs[newExprs.length-1];
                            newExprs[newExprs.length-1] = newExprs[newExprs.length-2];
                            newExprs[newExprs.length-2] = tmp;
                            default:
                        }
                        expr.expr = EBlock(newExprs);

                    default:
                }
                default:
            }
        }
        return fields;
    }
    #end
}