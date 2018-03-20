function build_arg_table()
    settings = ArgParseSettings(
        description="\033[32mNeuralNet\033[0m\n\n\n\n" *
        "\033[31m Simple Neural Net Framework for Binding Site Prediction t\033[0m"
    )

    @add_arg_table settings begin
        "predict"
            action = :command
            help = "run simple predictor"
        "simple_encoder"
            action = :command
            help = "run 8x3x8 encododer"
    end



    @add_arg_table settings["predict"] begin
        "-N"
            help = "Number of iterations to train neural net"
            default = 1000
            arg_type = Int
        "-a"
            help = "Learning Rate"
            default = 1e-3
            arg_type = Float64
        "--hl_size"
            help = "hidden layer size"
            default = 3
        "pos_seq"
            help = "data set of labeled sites"
            required = true
        "total_seq"
            help = "Fasta file for predictions"
            required = true
        "output_file"
            help = "File to output results to [.CSV, .TSV, etc]"
            required = true
    end

    settings["predict"].description = "Predicts on DNA sequences. "


    @add_arg_table settings["simple_encoder"] begin
        "-N"
            help = "Number of iterations to train neural net"
            default = 1000
            arg_type = Int
        "-a"
            help = "Learning Rate"
            default = 1e-3
            arg_type = Float64
        "output_file"
            help = "File to output results to [.CSV, .TSV, etc]"
            required = true
    end

    settings["simple_encoder"].description = "Runs the simple 8x3x8 predictor. "

    if typeof(Base.source_dir()) != Void
        settings.epilog = readstring(normpath(joinpath(Base.source_dir(),"..","LICENSE.md")))
    end

    return settings
end
