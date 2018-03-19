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

    settings["predict"].description = "Predicts on DNA sequences. "

    @add_arg_table settings["predict"] begin
        "--addprocs", "-p"
            help = "Add additional processors"
            arg_type = Int
            default = 1
        "data_set"
            help = "data set of labeled sites"
            required = true
        "sequence"
            help = "Fasta file for predictions"
            required = true
        "output_file"
            help = "File to output results to [.CSV, .TSV, etc]"
            required = true
    end

    settings["simple_encoder"].description = "Runs the simple 8x3x8 predictor. "

    @add_arg_table settings["predict"] begin
        "--addprocs", "-p"
            help = "Add additional processors"
            arg_type = Int
            default = 1
        "output_file"
            help = "File to output results to [.CSV, .TSV, etc]"
            required = true
    end

    if typeof(Base.source_dir()) != Void
        settings.epilog = readstring(normpath(joinpath(Base.source_dir(),"..","LICENSE")))
    end

    return settings
end
