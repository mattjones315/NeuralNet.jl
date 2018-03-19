using DataFrames;

"""
encode_8x3x8(N::Int, alpha::Float64, ofile::String)

This will run a very basic 8x3x8 encoder to verify that feed forward and back-
propagation setps work. It will -un the encoder for N iterations with a learning
rate of ALPHA and output updated weights to the file specified at OFILE.
"""
function encode_8x3x8(N, alpha, ofile)

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

            hidden, pred = feed_forward_encoder(inp, w1, w2)

            u1, u2 = backpropogate(pred, lab, hidden, w1, w2)

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
        hidden, pred = feed_forward_encoder(inp, w1, w2)

        raw[i,:] = pred
        output[i,:] = convert_to_one_hot(pred)
        h_output[i,:] = hidden[1:3]

        sserr += sum((pred - lab.').^2)
    end
    println(string("Sum of Squared Error: ", sserr))
    raw, output, h_output

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
function feed_forward_encoder(x, w1, w2)

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

    # Remove bias for update to first layer; i.e. inputs are not connected to
    # the hidden layer's bias term
    u1 = u1[1:3]

    u1, u2

end

function convert_to_one_hot(arr)

    for i in 1:length(arr)
        if arr[i] > 0.5
            arr[i] = 1
        else
            arr[i] = 0
        end
    end

    arr

end
