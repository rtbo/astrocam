// Tool to build and develop the VHDL in this folder
// Build command: dmd tool.d -oftool -O -release (or use mktool.sh)
// To get help: ./tool help
module tool;

import std.algorithm;
import std.array;
import std.file;
import std.json;
import std.path;
import std.process;
import std.stdio;

// Commands recognized by this tool
const commands = ["import", "make", "run", "wave", "clean"];
const defaultCmds = ["import", "make"];
const workDir = "work";

int usage(string prog, int result = 0, File output = stdout)
{
    output.writefln("%s [COMMANDS] [TARGETS] [-- args]", prog);
    output.writefln("Tool utility for astrocam VHDL code:");
    output.writefln("Available commands:");
    output.writefln("  import          Import source files");
    output.writefln("  make [TARGETS]  Build targets");
    output.writefln("  run [TARGETS]   Run simulation targets");
    output.writefln("  wave [TARGET]   Run GTKWave for the VCD file associated to target");
    output.writefln("  imr [TARGETS]   Shortcut for \"import make run [TARGET]\"");
    output.writefln("  mr [TARGETS]    Shortcut for \"make run [TARGET]\"");
    output.writefln("  mrw [TARGET]    Shortcut for \"make run wave [TARGET]\"");
    output.writefln("");
    output.writefln("If more than one command is provided, they are all run in the given order.");
    output.writefln(
            "If more than one target is provided, the commands are executed for each of them.");
    output.writefln("If no command is provided, \"make run\" is assumed by default.");
    output.writefln("If no target is provided, default is assumed from tool.json.");
    output.writefln("Additional arguments can be provided to the underlying tool after \"--\" "
            ~ "(Only works with single command).");
    return result;
}

string[] allVhdFiles()
{
    string[] result;
    foreach (entry; dirEntries(".", SpanMode.shallow))
    {
        if (entry.name.endsWith(".vhd"))
            result ~= entry.name;
    }
    return result;
}

int command(string[] cmd)
{
    writefln(cmd.join(" "));
    return spawnProcess(cmd).wait();
}

struct Target
{
    string name;
    string vcdFilename;
    bool isDefault;
}

int main(string[] args)
{
    const thisFile = __FILE_FULL_PATH__;
    const thisDir = dirName(thisFile);
    const thisExe = thisExePath;

    if (timeLastModified(thisFile) > timeLastModified(thisExe)) {
        stderr.writeln("WARNING: tool.d was modified but no recompiled.");
    }

    Target[string] targets;

    auto json = parseJSON(cast(const(string))read(buildPath(thisDir, "tool.json")));
    foreach (string name, JSONValue js; json["targets"])
    {
        Target target;
        target.name = name;
        if (!js["vcd"].isNull && js["vcd"].boolean) {
            target.vcdFilename = buildPath(thisDir, workDir, name.replace("_", "-") ~ ".vcd");
        }
        target.isDefault = !js["default"].isNull && js["default"].boolean;
        targets[name] = target;
    }
    const ghdlFlags = json["ghdl_flags"].array.map!(js => js.str).array;

    string[] cmds;
    Target[] tgts;
    string[] additionalArgs;

    foreach (i, arg; args[1 .. $])
    {
        if (arg == "help" || arg == "-h" || arg == "--help")
        {
            return usage(args[0]);
        }
        else if (arg == "imr")
        {
            cmds ~= ["import", "make", "run"];
        }
        else if (arg == "mr")
        {
            cmds ~= ["make", "run"];
        }
        else if (arg == "mrw")
        {
            cmds ~= ["make", "run", "wave"];
        }
        else if (arg == "--")
        {
            additionalArgs = args[i + 2 .. $]; // i is 0 for args[1]
            break;
        }
        else if (commands.canFind(arg))
        {
            cmds ~= arg;
        }
        else if (arg in targets)
        {
            tgts ~= targets[arg];
        }
        else
        {
            stderr.writefln("Error: Unknown operand: %s", arg);
            return usage(args[0], 1, stderr);
        }
    }

    if (!cmds)
    {
        cmds = defaultCmds.dup;
    }
    if (!tgts)
    {
        tgts = targets.values.filter!"a.isDefault".array;
    }

    const ghdl = environment.get("GHDL", "ghdl");
    const gtkwave = environment.get("GTKWAVE", "gtkwave");

    if (!exists("work"))
    {
        mkdir("work");
    }

    foreach (cmd; cmds)
    {
        if (cmd == "import")
        {
            const code = command([ghdl, "import"] ~ ghdlFlags ~ allVhdFiles);
            if (code != 0)
            {
                stderr.writeln("error during import command");
                return code;
            }
        }
        else if (cmd == "make")
        {
            foreach (tgt; tgts)
            {
                const code = command([ghdl, "make"] ~ ghdlFlags ~ tgt.name);
                if (code != 0)
                {
                    stderr.writefln("error during make command of %s", tgt.name);
                    return code;
                }
            }
        }
        else if (cmd == "run")
        {
            foreach (tgt; tgts)
            {
                auto c = [ghdl, "run"] ~ ghdlFlags ~ tgt.name;
                if (tgt.vcdFilename) {
                    c ~= "--vcd=" ~ tgt.vcdFilename;
                }
                const code = command(c);
                if (code != 0)
                {
                    stderr.writefln("error during run command of %s", tgt.name);
                    return code;
                }
            }
        }
        else if (cmd == "wave")
        {
            if (tgts.length != 1)
            {
                stderr.writefln("GtkWave can only be called with 1 target");
                return 3;
            }
            if (!tgts[0].vcdFilename)
            {
                stderr.writefln("No wave data for this target");
                return 4;
            }
            const code = command([gtkwave, tgts[0].vcdFilename]);
            if (code != 0)
            {
                stderr.writefln("error during wave command of %s", tgts[0].name);
                return code;
            }
        }
        else if (cmd == "clean")
        {
            rmdirRecurse("work");
            const patterns = ["*.vcd", "*.o"] ~ targets.keys;
            string[] toremove;

            foreach (entry; dirEntries(".", SpanMode.breadth))
            {
                foreach (pattern; patterns)
                {
                    if (globMatch(entry.name, pattern))
                    {
                        toremove ~= entry.name;
                    }
                }
            }

            toremove.each!(f => remove(f));
        }
    }

    return 0;
}
