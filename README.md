# NeuralNet

[![Build Status](https://travis-ci.org/mattjones315/NeuralNet.jl.svg?branch=master)](https://travis-ci.org/mattjones315/NeuralNet.jl)

# NeuralNet.jl

Here I've introduced a very basic neural net framework that supports only 3 layer neural nets, with variable sizes of the hidden layer. All output activation functions are sigmoidal.

# Getting Started

You can clone the repository with

```
git clone https://github.com/mattjones315/NeuralNet.jl
```

Before doing anything, install all the packages in the REQUIRE file. Then, run the following to make sure everything is working alright:

```
julia -e 'Pkg.clone(pwd()); Pkg.build(pwd()), Pkg.test(pwd(), coverage=true)'
```
# Using The Package

If you'd like to test the basic functionality of the package, use the autoencoder to find a low dimensional representation of one-hot 8 dimensional vectors. The results will be written to a file specified by some output file path.

```
julia src/run.jl simple_encoder -N 10000 -a 0.05 <output_file>
```

This will spawn a simple autoencoder instance, where we will train for 10000 epochs with a learning rate of 0.05.  

If you wish to train the neural net on actual sequences without predicting, you
may try the following

```
julia src/run.jl train_model -N 1000 -a 0.05 <pos_seqs> <total_seqs> <output_file>
```
This will train a three layer model over 1000 epochs with a learning rate of 0.05 on
the files you passed it. The file `total_seqs` consists of neutral DNA, and it will
be filtered, removing any positive sequences from the data as we construct our
positive and negatively-labeled data. By default, the model will be trained with
a hidden layer size of 3, over 10 cross validation rounds, and will consist of
perfectly balanced training data. You may review a list of all the commands with
the `-h` flag.

Finally, if you'd like to predict on unknown sequences, you may provide a test set as well, and use the `predict` module.

```
julia src/run.jl predict -N 1000 -a 0.05 <pos_data> <total_seqs> <predicting_data> <output>
```

All of the parameter defaults are the same as for the `train_model` module, only with this module we will be outputting probabilities that unknown sequences are actually transcription binding sequences.
