using ArgParse
using Compat
import Compat: UTF8String, ASCIIString, view, readstring, foreach

include("CLI.jl")
include("commands.jl")

function main()
    parsed_args = parse_args(build_arg_table())
    command = parsed_args["%COMMAND%"]

    if command == "help"
        foreach(x -> println(x), help())
    elseif command == "predict"
        predict(parsed_args[command]["data_set"],
        parsed_args[command]["sequence"],
        parsed_args[command]["output_file"],
        )
    elseif command == "simple_encoder"
        simple_encoder(parsed_args[command]["output_file"])
    else
        println("Command not recognized")
    end
end

# fire up simulation if run using command line
if !isinteractive()
    main()
end
