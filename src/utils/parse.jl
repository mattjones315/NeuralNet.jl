using FastaIO;

DNA_ONE_HOT = Dict("A" => [1,0,0,0], "C" => [0,1,0,0], "G" => [0,0,1,0], "T" => [0,0,0,1]);

function parse_training(pos_seq_fp, total_seq_fp; nr=100, balance=1)

    pos_mat = parse_seq(pos_seq_fp);

    neg_seqs = readfasta(total_seq_fp)[1:nr];
    neg_mat = zeros(Int, 1, size(pos_mat, 2));

    for seq in neg_seqs
        seq_segs = create_17b_segments(seq[2]);
        for seg in seq_segs
            oh = dna_to_one_hot(seg);
            neg_mat = vcat(neg_mat, oh.');
        end
    end
    neg_mat = neg_mat[2:end, :];

    neg_mat = filter_mats(pos_mat, neg_mat)

    neg_mat = neg_mat[rand(1:size(neg_mat, 1), size(pos_mat, 1)*balance),:]

    labels = ones(size(pos_mat, 1))
    labels = vcat(labels, zeros(size(neg_mat, 1)))

    training_data = vcat(pos_mat, neg_mat)

    training_data, labels


end

function parse_testing(test_fp)

    test_mat = parse_seq(test_fp)

    test_mat

end

function create_17b_segments(seq)

    seqs = []
    for i in 1:17:length(seq)
        if i + 16 < length(seq)
            push!(seqs, seq[i:i+16])
        end
    end

    seqs

end

# Hash function to compare sequences
function seq_hash(seq)

    tmp = seq .* 2.^collect(0:(length(seq)-1))
    sum(tmp)

end

function filter_mats(pos_mat, neg_mat)

    pos_hash = [seq_hash(pos_mat[i,:]) for i in 1:size(pos_mat, 1)]
    neg_hash = [seq_hash(neg_mat[i,:]) for i in 1:size(neg_mat, 1)]

    to_remove = []
    for i in 1:size(neg_hash, 1)
        if contains(==, neg_hash[i], pos_hash)
            push!(to_remove, i)
        end

        if length(neg_hash[neg_hash .== neg_hash[i]]) > 1
            push!(to_remove, i)
        end

    end


    neg_mat = neg_mat[setdiff(1:end, to_remove), :];

    neg_mat

end


function parse_seq(fp)

    f = open(fp, "r");
    l = collect(readlines(f));

    mat = zeros(Int, length(l), length(l[1]) * 4)

    for i in 1:length(l)

        seq = l[i]
        mat[i,:] = dna_to_one_hot(seq);

    end

    close(f);

    mat

end

convert_dna(x) = DNA_ONE_HOT[x];

function dna_to_one_hot(seq)
    one_hot = zeros(Int, 4, length(seq))
    for b in 1:length(seq)
        one_hot[:,b] = convert_dna(string(seq[b]))
    end

    collect(Iterators.flatten(one_hot));
end
