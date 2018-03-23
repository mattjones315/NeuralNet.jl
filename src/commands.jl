# Sane behavior when run from the REPL
source_dir = typeof(Base.source_dir()) == Void ? joinpath(Pkg.dir("NeuralNet"), "src") : Base.source_dir()

"""
align(algorithm::Compat.String, gap_penalty::Float64, gap_cont_penalty::Float64,
            seq1::Compat.String, seq2::Compat.String, smat::Compat.String, outputfile::Compat.String)
Align SEQ1 to SEQ2 using the scoring matrix SMAT and paramters GAP_PENALTY and GAP_CONT_PENALTY
for the ALGORITHM defined by user.
"""
function simple_encoder(N::Int, alpha::Float64, outputfile::Compat.String)


    include(joinpath(source_dir, "algorithms", "nn.jl"));
    # run
    Base.invokelatest(encode_8x3x8, N, alpha, outputfile);


end


function train_model(N::Int, alpha::Float64, hl_size::Int, write_output::Bool,
            balance::Int, C::Int, pos_seqs::Compat.String, total_seq::Compat.String, outputfile::Compat.String)

    include(joinpath(source_dir, "algorithms", "nn.jl"));
    include(joinpath(source_dir, "utils", "parse.jl"));


    tdata, labels = Base.invokelatest(parse_training, pos_seqs, total_seq, balance);

    Base.invokelatest(train_nn, tdata, labels, hl_size, N, alpha,
                        outputfile, write_output, C);

end

function predict(N::Int, alpha::Float64, hl_size::Int, write_output::Bool,
            balance::Int, C::Int, pos_seqs::Compat.String, total_seq::Compat.String,
            predict_seq::Compat.String, outputfile::Compat.String)

    include(joinpath(source_dir, "algorithms", "nn.jl"));
    include(joinpath(source_dir, "utils", "parse.jl"));


    tdata, labels = Base.invokelatest(parse_training, pos_seqs, total_seq, balance);
    test_data = Base.invokelatest(parse_testing, predict_seq)

    Base.invokelatest(nn_predict_on_data, tdata, labels, test_data, hl_size, N, alpha,
                        outputfile, write_output, C);

end
