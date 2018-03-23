

ONE_HOT_TO_DNA = Dict([1,0,0,0] => "A", [0,1,0,0] => "C", [0,0,1,0] => "G", [0,0,0,1] => "T");

convert_one_hot(x) = ONE_HOT_TO_DNA[x];

function one_hot_to_dna(seq)
    dna = ""
    for b in 1:4:length(seq)
         dna = string(dna, convert_one_hot(seq[b:b+3]));
    end

    dna
end


"""
encode_8x3x8(N::Int, alpha::Float64, ofile::String)

This will run a very basic 8x3x8 encoder to verify that feed forward and back-
propagation setps work. It will -un the encoder for N iterations with a learning
rate of ALPHA and output updated weights to the file specified at OFILE.
"""
function encode_8x3x8(N, alpha, ofile; write_output = false, verbose = true)

    input = one_hot_8x3x8(8)

    # Add a bias term to the input
    input = hcat(ones(8, 1), input)

    labels = one_hot_8x3x8(8)

    # draw random weights for first layer to hidden layaer
    w1 = rand(9, 3)
    # draw random weights for hidden layer to output layer
    w2 = rand(4, 8)

    for j in 1:N
        for i in 1:size(input, 1)

            inp = input[i,:]
            lab = labels[i,:]

            hidden, pred = feedforward(inp, w1, w2)

            u1, u2 = backpropogate(pred, lab, hidden, w1, w2)
            u1 = u1[1:3]

            # Now update weights
            w1 -= alpha * (u1.' * inp.').'
            w2 -= alpha * (u2.' * hidden).'

        end
    end

    # Report final predictions
    output = zeros(8,8)
    raw = zeros(8, 8)
    h_output = zeros(8, 3)

    sserr = 0.0
    for i in 1:size(input, 1)

        inp = input[i,:]
        lab = labels[i,:]
        hidden, pred = feedforward(inp, w1, w2)

        raw[i,:] = pred
        output[i,:] = threshold(pred)
        h_output[i,:] = hidden[1:3]

        sserr += sum((pred - lab.').^2)
    end

    if verbose
        println(string("Sum of Squared Error: ", sserr))
    end

    if write_output
        write_results(output, h_output, ofile)
    end

    raw, output, h_output, sserr

end

function nn_predict_on_data(tdata, labels, test_data, hl_size, N, alpha, ofile; write_output=true, verbose=false, C=100)
    # Add bias term to training data
    tdata = hcat(ones(size(tdata, 1), 1), tdata);

    # draw random weights for input layer to hidden layer
    w1 = rand(size(tdata, 2), hl_size);
    # draw random weights for hidden layer to output layer
    w2 = rand(hl_size+1, size(labels, 2));

    # Cross-Validate C times
    total_accuracy = 0.0
    for c in 1:C

        println(string("Cross Validation Round: ", c))

        # Select 90% as training and 10% as testing
        train_ii = rand(1:size(tdata, 1), convert(Int, round(0.9 * size(tdata, 1))));
        test_ii = setdiff(1:size(tdata, 1), train_ii);

        training_input = tdata[train_ii,:];
        training_labels = labels[train_ii, :];

        test_input = tdata[test_ii,:];
        test_labels = labels[test_ii,:];

        for j in 1:N

            if j % 100 == 0
                println(string("Epoch: ", j));
            end

            for i in 1:size(training_input, 1)

                inp = training_input[i,:];
                lab = training_labels[i,:];

                hidden, pred = feedforward(inp, w1, w2);

                u1, u2 = backpropogate(pred, lab, hidden, w1, w2);
                u1 = u1[1:hl_size];

                # Now update weights
                w1 -= alpha * (u1.' * inp.').';
                w2 -= alpha * (u2.' * hidden).';
            end

        end

        # Now test on the held out data to see how we did
        predictions = zeros(size(test_labels));
        prob_predictions = zeros(size(test_labels))
        dna_seqs = Array{String, 1}(size(test_labels, 1))
        for i in 1:size(test_input, 1)

            inp = test_input[i,:];
            lab = test_labels[i,:];
            hidden, pred = feedforward(inp, w1, w2);

            prob_predictions[i,:] = pred;
            predictions[i,:] = threshold(pred);

            # Remove bias term from the input for converting back to dna sequences
            dna_seqs[i] = one_hot_to_dna(inp[2:end]);

        end

        accuracy = calc_accuracy(test_labels, predictions);
        println(string("Accuracy: ", accuracy))

        total_accuracy += accuracy;
    end

    println(string("~~~~~~~Final Cross-Validation Accuracy~~~~~~\n", total_accuracy / C));

    if write_output

        # Add bias term for test_data to pass through neural network
        test_data = hcat(ones(size(test_data, 1), 1), test_data);

        prob_predictions = zeros(size(test_data, 1))
        dna_seqs = Array{String, 1}(size(test_data, 1))

        for i in 1:size(test_data, 1)

            inp = test_data[i,:];
            hidden, pred = feedforward(inp, w1, w2);

            prob_predictions[i,:] = pred;

            # Remove bias term from the input for converting back to dna sequences
            dna_seqs[i] = one_hot_to_dna(inp[2:end]);

        end


        write_seq_predictions(dna_seqs, prob_predictions, ofile);

    end

    total_accuracy / C

end

function train_nn(tdata, labels, hl_size, N, alpha, ofile; write_output = true, verbose = false, C=100)

    # Add bias term to training data
    tdata = hcat(ones(size(tdata, 1), 1), tdata);

    # Cross-Validate C times
    total_accuracy = 0.0
    for c in 1:C

        println(string("Cross Validation Round: ", c))

        # Select 90% as training and 10% as testing
        train_ii = rand(1:size(tdata, 1), convert(Int, round(0.9 * size(tdata, 1))));
        test_ii = setdiff(1:size(tdata, 1), train_ii);

        training_input = tdata[train_ii,:];
        training_labels = labels[train_ii, :];

        test_input = tdata[test_ii,:];
        test_labels = labels[test_ii,:];

        # draw random weights for input layer to hidden layer
        w1 = rand(size(training_input, 2), hl_size);
        # draw random weights for hidden layer to output layer
        w2 = rand(hl_size+1, size(training_labels, 2));


        for j in 1:N

            if j % 100 == 0
                println(string("Epoch: ", j));
            end

            for i in 1:size(training_input, 1)

                inp = training_input[i,:];
                lab = training_labels[i,:];

                hidden, pred = feedforward(inp, w1, w2);

                u1, u2 = backpropogate(pred, lab, hidden, w1, w2);
                u1 = u1[1:hl_size];

                # Now update weights
                w1 -= alpha * (u1.' * inp.').';
                w2 -= alpha * (u2.' * hidden).';
            end

        end

        # Now test on the held out data to see how we did
        predictions = zeros(size(test_labels));
        prob_predictions = zeros(size(test_labels))
        dna_seqs = Array{String, 1}(size(test_labels, 1))
        for i in 1:size(test_input, 1)

            inp = test_input[i,:];
            lab = test_labels[i,:];
            hidden, pred = feedforward(inp, w1, w2);

            prob_predictions[i,:] = pred;
            predictions[i,:] = threshold(pred);

            # Remove bias term from the input for converting back to dna sequences
            dna_seqs[i] = one_hot_to_dna(inp[2:end]);

        end

        # if we want, we can just write out the last set of dna_seqs and probability
        # that they're binding sites
        if c == C && write_output
            write_seq_predictions(dna_seqs, prob_predictions, ofile);
        end

        accuracy = calc_accuracy(test_labels, predictions);
        println(string("Accuracy: ", accuracy))

        total_accuracy += accuracy;
    end

    println(string("~~~~~~~Final Accuracy~~~~~~\n", total_accuracy / C));

    total_accuracy / C


end

function nn_3layer(input, labels, hl_size, N, alpha, ofile; verbose = false)

    # Add bias term to input layer
    input = hcat(ones(size(input, 1), 1), input);

    # draw random weights for first layer to hidden layaer
    w1 = rand(size(input, 2), hl_size);
    # draw random weights for hidden layer to output layer
    w2 = rand(hl_size+1, size(labels, 2));

    for j in 1:N

        if j % 100 == 0
            println(string("Epoch: ", j));
        end

        for i in 1:size(input, 1)

            inp = input[i,:];
            lab = labels[i,:];

            hidden, pred = feedforward(inp, w1, w2);

            u1, u2 = backpropogate(pred, lab, hidden, w1, w2);
            u1 = u1[1:hl_size];

            # Now update weights
            w1 -= alpha * (u1.' * inp.').';
            w2 -= alpha * (u2.' * hidden).';
        end

    end

    output = zeros(size(labels));
    raw = zeros(size(labels));
    h_output = zeros(size(labels, 1), hl_size);

    sserr = 0.0
    for i in 1:size(input, 1)

        inp = input[i,:];
        lab = labels[i,:];
        hidden, pred = feedforward(inp, w1, w2);

        raw[i,:] = pred;
        output[i,:] = threshold(pred);
        h_output[i,:] = hidden[1:hl_size];

        sserr += sum((pred - lab.').^2);
    end

    accuracy = calc_accuracy(labels, output);

    println(string("Sum of Squared Error: ", sserr));
    println(string("Final Prediction Accuracy: ", accuracy));
    raw, output, h_output, sserr, accuracy

end

function calc_accuracy(labels, output)

    accur = 0.0
    for i in 1:size(labels, 1)

        if labels[i,:] == output[i,:]
            accur += 1
        end
    end

    accur / size(labels, 1)
end


function one_hot_8x3x8(n)

    eye(n)

end

# Define sigmoid activation function
sigmoid(x) = 1 / (1 + exp(-x))

"""
feed_forward_encoder(input::Array{Float64, 2}, w1::Array{Float64, 2}, w2::Array{Float64, 2})

Feed an INPUT array through a simple 8x3x8 encoder with input weights W1 and
hidden layer weights W2. Report back the hidden predictions as well as the
output predictions.
"""
function feedforward(x, w1, w2)

    # Feed to first layer
    h = x.' * (w1)
    hp = sigmoid.(h)
    hp = hcat(hp, 1)

    pred = sigmoid.(hp * w2)
    hp, pred

end

function backpropogate(predictions, label, hl, w1, w2)

    u2 = predictions .* (1 - predictions) .* (predictions - label.')

    u1 = hl .* (1 - hl) .* (w2 * u2.').'

    u1, u2

end

function threshold(arr)

    for i in 1:length(arr)
        if arr[i] > 0.5
            arr[i] = 1
        else
            arr[i] = 0
        end
    end

    arr

end

function write_results(output, preds, ofile)

    open(ofile, "w") do f

        for i in 1:size(output, 1)
            write(f, string(output[i,:], "\t", preds[i,:], "\n"))
        end
    end
end

function write_seq_predictions(output, preds, ofile)

    open(ofile, "w") do f

        for i in 1:size(output, 1)
            write(f, string(output[i,:][1], "\t", preds[i,:][1], "\n"))
        end
    end
end
