# Sane behavior when run from the REPL
source_dir = typeof(Base.source_dir()) == Void ? joinpath(Pkg.dir("NeuralNet"), "src") : Base.source_dir()

"""
align(algorithm::Compat.String, gap_penalty::Float64, gap_cont_penalty::Float64,
            seq1::Compat.String, seq2::Compat.String, smat::Compat.String, outputfile::Compat.String)
Align SEQ1 to SEQ2 using the scoring matrix SMAT and paramters GAP_PENALTY and GAP_CONT_PENALTY
for the ALGORITHM defined by user.
"""
function simple_encoder(outputfile::Compat.String)


    include(joinpath(source_dir, "algorithms", "nn.jl"));
    # run
    Base.invokelatest(encode_8x3x8, outputfile);
    end

end
