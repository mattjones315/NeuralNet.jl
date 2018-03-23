using ArgParse
using Compat
import Compat: UTF8String, ASCIIString, view, readstring, foreach

include("CLI.jl")
include("commands.jl")

function main()
    parsed_args = parse_args(build_arg_table())
    command = parsed_args["%COMMAND%"]
    println(typeof(parsed_args[command]["N"]))

    if command == "help"
        foreach(x -> println(x), help())
    elseif command == "train_model"
        train_model(parsed_args[command]["N"],
        parsed_args[command]["a"],
        parsed_args[command]["hl_size"],
        parsed_args[command]["w"],
        parsed_args[command]["b"],
        parsed_args[command]["C"],
        parsed_args[command]["pos_seq"],
        parsed_args[command]["total_seq"],
        parsed_args[command]["output_file"]
        )
    elseif command == "predict"
        predict(parsed_args[command]["N"],
        parsed_args[command]["a"],
        parsed_args[command]["hl_size"],
        parsed_args[command]["w"],
        parsed_args[command]["b"],
        parsed_args[command]["C"],
        parsed_args[command]["pos_seq"],
        parsed_args[command]["total_seq"],
        parsed_args[command]["predict_seq"],
        parsed_args[command]["output_file"]
        )
    elseif command == "simple_encoder"
        simple_encoder(parsed_args[command]["N"],
            parsed_args[command]["a"],
            parsed_args[command]["output_file"])
    else
        println("Command not recognized")
    end
end

# fire up simulation if run using command line
if !isinteractive()
    main()
end
