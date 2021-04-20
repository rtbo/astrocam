// Tool to build and develop the VHDL in this folder
// Build command: dmd tool.d -oftool -O -release
// To get help: ./tool help
module tool;

import std.algorithm;
import std.array;
import std.file;
import std.process;
import std.stdio;

// Commands recognized by this tool
const commands = ["import", "make", "run", "wave"];
// Targets recognized by this tool
const targets = ["ccd_drive_tb"];

const defaultCmds = ["import", "make"];
const defaultTargets = ["ccd_drive_tb"];

const ghdlFlags = ["--workdir=work", "--work=astrocam", "--std=08"];

int usage(string prog, int result = 0, File output = stdout)
{
    output.writefln("%s [COMMANDS] [TARGETS] [-- args]", prog);
    output.writefln("Tool utility for astrocam VHDL code:");
    output.writefln("Available commands:");
    output.writefln("  import          Import source files");
    output.writefln("  make [TARGETS]  Build targets");
    output.writefln("  run [TARGETS]   Run simulation targets");
    output.writefln("  wave [TARGET]   Run GTKWave for the VCD file associated to target");
    output.writefln("  mrw [TARGET]    Shortcut for \"make run wave [TARGET]\"");
    output.writefln("  mr [TARGETS]    Shortcut for \"make run [TARGET]\"");
    output.writefln("");
    output.writefln("If more than one command is provided, they are all run in the given order.");
    output.writefln(
            "If more than one target is provided, the commands are executed for each of them.");
    output.writefln("If no command is provided, \"make run\" is assumed by default.");
    output.writefln("If no target is provided, \"ccd_drive_tb\" is assumed by default.");
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

int main(string[] args)
{
    string[] cmds;
    string[] tgts;
    string[] additionalArgs;

    foreach (i, arg; args[1 .. $])
    {
        if (arg == "help" || arg == "-h" || arg == "--help")
        {
            return usage(args[0]);
        }
        else if (arg == "mrw")
        {
            cmds ~= ["make", "run", "wave"];
        }
        else if (arg == "mr")
        {
            cmds ~= ["make", "run"];
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
        else if (targets.canFind(arg))
        {
            tgts ~= arg;
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
        tgts = defaultTargets.dup;
    }

    const ghdl = environment.get("GHDL", "ghdl");
    const gtkwave = environment.get("GTKWAVE", "gtkwave");

    // mapping of target to VCD file
    const vcds = ["ccd_drive_tb" : "ccd-drive.vcd"];

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
                const code = command([ghdl, "make"] ~ ghdlFlags ~ tgt);
                if (code != 0)
                {
                    stderr.writefln("error during make command of %s", tgt);
                    return code;
                }
            }
        }
        else if (cmd == "run")
        {
            foreach (tgt; tgts)
            {
                auto c = [ghdl, "run"] ~ ghdlFlags ~ tgt;
                auto p = tgt in vcds;
                if (p)
                    c ~= "--vcd=" ~ *p;
                const code = command(c);
                if (code != 0)
                {
                    stderr.writefln("error during run command of %s", tgt);
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
            if (!(tgts[0] in vcds))
            {
                stderr.writefln("No wave data for this target");
                return 4;
            }
            const code = command([gtkwave, vcds[tgts[0]]]);
            if (code != 0)
            {
                stderr.writefln("error during wave command of %s", tgts[0]);
                return code;
            }
        }
    }

    return 0;
}
