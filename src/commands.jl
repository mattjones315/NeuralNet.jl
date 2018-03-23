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


function train_model(N::Int, alpha::Float64, hl_size::Int, pos_seqs::Compat.String,
            total_seq::Compat.String, outputfile::Compat.String)

    include(joinpath(source_dir, "algorithms", "nn.jl"));
    include(joinpath(source_dir, "utils", "parse.jl"));

    Base.invokelatest(nn_3layer, Base.invokelatest(parse_input, pos_seqs, total_seq),
                        hl_size, N, alpha, outputfile);

end
