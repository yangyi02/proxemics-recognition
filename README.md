# Recognizing Proxemics in Personal Photos 

## Introduction

This is a Matlab implementation of proxemics recognition described in [1]. It includes a completely new dataset with training, testing, evaluation and visualization code. Much of the training and detection code is built on top of flexible mixtures of part model [2] and part based model [3]. The training code implements a quadratic program (QP) solver described in [4].

To illustrate the use of the training code, this package uses positive images from the new PROXEMICS dataset, and negative images from the INRIA Person Background dataset [5]. We also include the new Percentage of Correctly Localized Keypoints (PCK) evaluation code from [6] for benchmark evaluation on pose estimation.

Compatibility issues: The training code may require 4.5GB of memory. Modify line 32/33 in `learning/train.m` to use less memory at the cost of longer training times.

The code also makes use of the face detection results obtained from Microsoft Research. 

Acknowledgements: We graciously thank the authors of the previous code releases and image benchmarks for making them publically available.

## Using the code

1. Download the [PROXMEMICS dataset (89MB)](https://www.dropbox.com/s/5zarkyny7ywc2fv/PROXEMICS.zip?dl=0) and [INRIA Person Background dataset (59MB)](https://www.dropbox.com/s/jtnticywxulfnq6/INRIA.zip?dl=0), put them into `data/PROXEMICS` and `data/INRIA` respectively. Or you can simply call `bash download_data.sh`.
2. Start matlab (version >2013a).
3. Run `compile.m` to compile the helper functions. (you may also edit `compile.m` to use a different convolution routine depending on your system)
4. Run `PROXSUB_demo.m` to see the training and detecting one particular proxemic submixture.
5. Or run `PROX_demo.m` to see the complete system for training and detecting one particular proxemic.
6. By default, the code is set to output the highest-scoring detection in an image given the two people's face bounding boxes detected from a face detector.

## References

[1] Y. Yang, S. Baker, A. Kannan, D. Ramanan. [Recognizing Proxemics in Personal Photos](https://yangyi02.github.io/research/proxemics/proxemics_cvpr2012.pdf). CVPR 2012.

[2] Y. Yang, D. Ramanan. Articulated Pose Estimation using Flexible Mixtures of Parts. CVPR 2011.

[3] P. Felzenszwalb, R. Girshick, D. McAllester. [Discriminatively Trained Deformable Part Models](http://www.rossgirshick.info/latent/). PAMI 2010.

[4] D. Ramanan. Dual Coordinate Descent Solvers for Large Structured Prediction Problems. UCI Technical Report.

[5] N. Dalal, B. Triggs. Histograms of Oriented Gradients for Human Detection. CVPR 2005.

[6] Y. Yang, D. Ramanan. Articulated Human Detection with Flexible Mixtures of Parts. PAMI 2013.
