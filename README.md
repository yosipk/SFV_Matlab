Set up a root dir with following subdirectoreis:
* labels 
* data
* cache
* results

The directory 'labels' should contain following files:
* train_labels.list - one column file, one row per image, 1 if it's train+val, 0 if it's test image
* class_labels.list - a column per class, one row per image, 1 if it's positive for class 0 if it's negative for class
* image_sizes.list - two column file, one row per image, first column is width, second is image height
* images.list - a list of images that can be found in 'data' directory 

The examples of these files for Pascal2007 dataset are in file pascal_labels.tar.bz2

The directory 'data' should contain features for image, one set of images per file in %06d format (zero filled from left to 6 places), eg. data from image with ID 1 is in file 000001.mat
Each file contains two arrays:
* d is D x N array of patch appearance descriptors (eg. for SIFT D = 128)
* f is 4 x N array of patch position descriptors:
  * first two rows describe the position of the patch (x,y) in the image plane
  * the last row is the patch size

SIFT descriptors can be extracted using [VLFeat](http://www.vlfeat.org).

Once the labels are prepared and features are extracted and saved to data dir, all the
parameters of the pipeline can be learned by running the main script (classif_pipeline.m).
Before, make sure you have [YAEL](http://yael.gforge.inria.fr) and [LIBSVM](https://www.csie.ntu.edu.tw/~cjlin/libsvm/) installed. 

Example:
~~~~
libsvm_path = PATH_TO_LIBSVM_MATLAB_INTERFACE;
yael_path = PATH_TO_YAEL_MATLAB_INTERFACE;
root_dir = PATH_TO_ROOT_DIR; % that contains 4 subdirectories
classif_pipeline
~~~~

Inside the script all the parameters of the process are set: the number of appearance and
position components, the type of appearance and position models, the normalizations, the
parameters of SVM, ...

Running script will learn all the generative models, create Fisher vector representations for the images, normalize them, learn and test SVM classification models and dump the results in results dir.

For multi-class logistic regression the function logregFit from [PMTK3](http://code.google.com/p/pmtk3) can be used.

If you use this code for your publication, please cite our ICCV 2011 paper:

[Krapac, Verbeek, Jurie: "Modeling Spatial Layout with Fisher Vectors for Image
Categorization", ICCV 2011](http://hal.inria.fr/inria-00612277/en).
