# proxemics_recognition
[CVPR 2012] Matlab code for Recognizing Proxemics in Personal Photos

## Introduction

This is a matlab implementation of the proxemics recognition algorithm described in [1]. It includes a completely new dataset with training, testing, evaluation and visualization code. Much of the training and detection code is built on top of flexible mixtures of part model [2] and part based model [3]. The training code implements a quadratic program (QP) solver described in [4].

To illustrate the use of the training code, this package uses images from the new PROXEMICS dataset, and negative images from the INRIA Person dataset [5]. We use also include the new Percentage of Correctly Localized Keypoints (PCK) evaluation code from [6] for benchmark evaluation on pose estimation.

Compatibility issues: The training code may require 6GB of memory. Uncomment/comment line 33/34 in learning/train.m to use less memory at the cost of longer training times.

The code also makes use of the face detection results obtained from Microsoft Research. 

Acknowledgements: We graciously thank the authors of the previous code releases and image benchmarks for making them publically available.

## Using the code

1. Download the PROXMEMICS dataset(89MB) and INRIA Person dataset(59MB), put them into data/PROXEMICS and data/INRIA respectively. Or you can call ``bash download_data.sh''.
2. Start matlab
3. Run the 'compile' script to compile the helper functions. (you may want to edit compile.m to use a different convolution  routine depending on your system)
4. Run 'PROX_demo' to see an example of the complete system for training and detecting one particular proxemics.
5. Or you can run 'PROXSUB_demo' to see an example of the complete system for training and detecting one particular proxemics submixture (Divided by left & right).
5. By default, the code is set to output the highest-scoring detection in an image given the two people's face bounding boxes detected from a face detector.

## References

[1] Y. Yang, S. Baker, A. Kannan, D. Ramanan. Recognizing Proxemics in Personal Photos. CVPR 2012.

[2] Y. Yang, D. Ramanan. Articulated Pose Estimation using Flexible Mixtures of Parts. CVPR 2011.

[3] P. Felzenszwalb, R. Girshick, D. McAllester. Discriminatively Trained Deformable Part Models. http://people.cs.uchicago.edu/~pff/latent.

[4] D. Ramanan. Dual Coordinate Descent Solvers for Large Structured Prediction Problems. UCI Technical Report, to appear.

[5] N. Dalal, B. Triggs. Histograms of Oriented Gradients for Human Detection. CVPR 2005.

[6] Y. Yang, D. Ramanan. Articulated Human Detection with Flexible Mixtures of Parts. Submitted to PAMI.
