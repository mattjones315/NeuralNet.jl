
using Base.Test

source_dir = pwd()

include(joinpath(source_dir, "../src", "algorithms", "nn.jl"));
include(joinpath(source_dir, "../src", "utils", "parse.jl"));

# write your own tests here
function test_parser()

    ## assume for now that we have data in the "data" directory as given
    ## to us from the assignment

    pos_seq_fp = "../data/rap1-lieb-positives.txt";
    total_seq_fp = "../data/yeast-upstream-1k-negative.fa";

    tdata, labels = parse_training(pos_seq_fp, total_seq_fp; balance=1);

    @test size(tdata, 1) == size(labels, 1);

    @test size(tdata, 2) == 68;

end

function test_basic_autoencoder()

    results = encode_8x3x8(100000, 0.05, ""; write_output = false, verbose = true)


    # make sure results are the right dimension
    @test size(results[1], 1) == 8
    @test size(results[1], 2) == 8

    @test size(results[3], 1) == 8
    @test size(results[3], 2) == 3

    #make sure we were able to train correctly with these parameters
    @test results[2] == one_hot_8x3x8(8)

end

function test_feedforward()

    tdata = one_hot_8x3x8(8)

    tdata = hcat(ones(8, 1), tdata)

    labels = one_hot_8x3x8(8)

    # draw random weights for first layer to hidden layaer
    w1 = rand(9, 3)
    # draw random weights for hidden layer to output layer
    w2 = rand(4, 8)

    # make sure feedforward works correctly
    hidden, pred = feedforward(tdata[1,:], w1, w2)

    # number of columns should correspond to number of hidden nodes + bias term
    @test size(hidden, 2) == 4

    # remove the bias term dimension
    @test size(pred, 2) == size(tdata, 1)

    # make sure that we're outputing probabilities
    @test sum(pred .<= 1) == size(pred, 2)
    @test sum(hidden .<= 1) == size(hidden, 2)

end

function test_backprop()

    tdata = one_hot_8x3x8(8);

    tdata = hcat(ones(8, 1), tdata)

    labels = one_hot_8x3x8(8)

    # draw random weights for first layer to hidden layaer
    w1 = rand(9, 3)
    # draw random weights for hidden layer to output layer
    w2 = rand(4, 8)

    # make sure feedforward works correctly
    hidden, pred = feedforward(tdata[1,:], w1, w2)

    u1, u2 = backpropogate(pred, lab, hidden, w1, w2)
    u1 = u1[1:3]

    u1 = (u1.' * inp.').'
    u2 = (u2.' * hidden).'

    # make sure that the weight can be updated correctly
    @test size(u1) == w1;
    @test size(u2) == w2;

end

function test_threshold()

    tdata = one_hot_8x3x8(8);

    tdata = hcat(ones(8, 1), tdata)

    labels = one_hot_8x3x8(8)

    # draw random weights for first layer to hidden layaer
    w1 = rand(9, 3)
    # draw random weights for hidden layer to output layer
    w2 = rand(4, 8)

    # make sure feedforward works correctly
    hidden, pred = feedforward(tdata[1,:], w1, w2)

    pred = threshold(pred)

    # make sure we're outputing either zeros or ones here
    @test sum(pred .== 1 || pred .== 0) == size(pred, 2)

end


test_parser()
test_basic_autoencoder()
test_feedforward()
