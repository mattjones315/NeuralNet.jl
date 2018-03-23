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
        "train_model"
            action = :command
            help = "train the neural net on sequence data"
    end




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


    @add_arg_table settings["train_model"] begin
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
            arg_type = Int
            default = 3
        "-w"
            help = "Choose whether or not to write output"
            default = true
        "-b"
            help = "Class inbalance parameter"
            arg_type = Int
            default = 1
        "-C"
            help = "Number of cross-validation rounds"
            arg_type = Int
            default = 10
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

    settings["train_model"].description = "Trains the neural net for testing purposes."

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
            arg_type = Int
            default = 3
        "-w"
            help = "Choose whether or not to write output"
            default = true
        "-b"
            help = "Class inbalance parameter"
            arg_type = Int
            default = 1
        "-C"
            help = "Number of cross-validation rounds"
            arg_type = Int
            default = 10
        "pos_seq"
            help = "data set of labeled sites"
            required = true
        "total_seq"
            help = "Fasta file for predictions"
            required = true
        "predict_seq"
            help = "Contains the sequences you wish to predict"
            required = true
        "output_file"
            help = "File to output results to [.CSV, .TSV, etc]"
            required = true
    end

    settings["train_model"].description = "Trains the neural net for testing purposes."

    if typeof(Base.source_dir()) != Void
        settings.epilog = readstring(normpath(joinpath(Base.source_dir(),"..","LICENSE.md")))
    end

    return settings
end
