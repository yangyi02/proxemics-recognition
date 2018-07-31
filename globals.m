% --------------------
% Set up public paths
% --------------------
addpath learning;
addpath detection;
addpath visualization;
addpath evaluation;
if isunix()
  addpath mex_unix;
elseif ispc()
  addpath mex_pc;
end

% directory for caching models, intermediate data, and results
cachedir = 'cache/';
if ~exist(cachedir,'dir')
  mkdir(cachedir);
end

% --------------------
% Set up model structures and hyperparameters for proxemic codes
% Original ground truth labeling for every person:
% 1. Top head 2. Neck 3. Left Shoulder 4. Left Elbow 5. Left Wrist 6. Left Hand
% 7. Right Shoulder 8. Right Elbow 9. Right Wrist 10. Right Hand
% --------------------
% global setting for hand touch hand
PROXopts(1).name = 'HH';
PROXopts(1).submix(1).name = 'LHLH';
PROXopts(1).submix(1).pts1 = [1 2 3 4 5 6];
PROXopts(1).submix(1).pts2 = [6 5 4 3 2 1];
PROXopts(1).submix(1).touchnum = 1;
PROXopts(1).submix(2).name = 'LHRH';
PROXopts(1).submix(2).pts1 = [1 2 3 4 5 6];
PROXopts(1).submix(2).pts2 = [10 9 8 7 2 1];
PROXopts(1).submix(2).touchnum = 2;
PROXopts(1).submix(3).name = 'RHLH';
PROXopts(1).submix(3).pts1 = [1 2 7 8 9 10];
PROXopts(1).submix(3).pts2 = [6 5 4 3 2 1];
PROXopts(1).submix(3).touchnum = 3;
PROXopts(1).submix(4).name = 'RHRH';
PROXopts(1).submix(4).pts1 = [1 2 7 8 9 10];
PROXopts(1).submix(4).pts2 = [10 9 8 7 2 1];
PROXopts(1).submix(4).touchnum = 4;

PROXopts(1).K = [4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4];
PROXopts(1).pa = [0 1 2 3 4 5 6 7 8  9  10 11 12 13 14 15];
PROXopts(1).co = [2 1 2 3 4 5 6 7 10 11 12 13 14 15 16 15];
PROXopts(1).faceid = [1 16];

PROXopts(1).color = {'g','g','y','r','r','b','b','c',...
                     'c','b','b','r','r','y','g','g'};

% Original labeling:
% 1. Top Head 2. Neck 3. Shoulder 4. Elbow 5. Wrist 6. Hand
% 7. Hand 8. Wrist 9. Elbow 10. Shoulder 11. Neck 12. Top Head
% After Transformation:
% 1. Head 2. Shoulder 3. Upp Arm 4. Elbow 5. Low Arm 6. Wrist 7. Hand
% 8. Hand 9. Wrist 10. Low Arm 11. Elbow 12. Upp Arm 13. Shoulder 14. Head
I = [1   1   2 3 4   4   5 6   6   7 8 9  10 11  11  12 13  13  14 15 16  16];
J = [1   2   2 3 3   4   4 4   5   5 6 7  8  8   9   9  9   10  10 11 11  12];
A = [1/2 1/2 1 1 1/2 1/2 1 1/2 1/2 1 1 1  1  1/2 1/2 1  1/2 1/2 1  1  1/2 1/2];
PROXopts(1).trans = full(sparse(I,J,A,16,12));

% For pose estimation evaluation
% 1. Head 2. Shoulder 3. Elbow 4. Wrist
% 5. Wrist 6. Elbow 7. Shoulder 8. Head
I = [1 2 3 4 5  6  7  8];
J = [1 3 5 7 10 12 14 16];
A = [1 1 1 1 1  1  1  1];
PROXopts(1).transback = full(sparse(I,J,A,8,16));


% --------------------
% global setting for hand touch shoulder
PROXopts(2).name = 'HS';
PROXopts(2).submix(1).name = 'LHLS';
PROXopts(2).submix(1).pts1 = [1 2 3 4 5 6];
PROXopts(2).submix(1).pts2 = [3 2 1];
PROXopts(2).submix(1).touchnum = 5;
PROXopts(2).submix(2).name = 'LHRS';
PROXopts(2).submix(2).pts1 = [1 2 3 4 5 6];
PROXopts(2).submix(2).pts2 = [7 2 1];
PROXopts(2).submix(2).touchnum = 6;
PROXopts(2).submix(3).name = 'RHLS';
PROXopts(2).submix(3).pts1 = [1 2 7 8 9 10];
PROXopts(2).submix(3).pts2 = [3 2 1];
PROXopts(2).submix(3).touchnum = 7;
PROXopts(2).submix(4).name = 'RHRS';
PROXopts(2).submix(4).pts1 = [1 2 7 8 9 10];
PROXopts(2).submix(4).pts2 = [7 2 1];
PROXopts(2).submix(4).touchnum = 8;

PROXopts(2).K = [4 4 4 4 4 4 4 4 4 4 4];
PROXopts(2).pa = [0 1 2 3 4 5 6 7 8 9 10];
PROXopts(2).co = [2 1 2 3 4 5 6 7 10 11 10];
PROXopts(2).faceid = [1 11];

PROXopts(2).color = {'g','g','y','r','r','b','b','c','y','g','g'};
                        
% Original labeling:
% 1. Top Head 2. Neck 3. Shoulder 4. Elbow 5. Wrist 6. Hand
% 7. Shoulder 8. Neck 9. Top Head
% After Transformation:
% 1. Head 2. Neck 3. Shoulder 4. Upp Arm 5. Elbow 6. Low Arm 7. Wrist 8. Hand
% 9. Shoulder 10. Neck 11. Head
I = [1   1   2 3 4   4   5 6   6   7 8 9 10 11  11];
J = [1   2   2 3 3   4   4 4   5   5 6 7 8  8   9];
A = [1/2 1/2 1 1 1/2 1/2 1 1/2 1/2 1 1 1 1  1/2 1/2];
PROXopts(2).trans = full(sparse(I,J,A,11,9));

% For pose estimation evaluation
% 1. Head 2. Shoulder 3. Elbow 4. Wrist
% 5. Shoulder 6. Head
I = [1 2 3 4 5 6];
J = [1 3 5 7 9 11];
A = [1 1 1 1 1 1];
PROXopts(2).transback = full(sparse(I,J,A,6,11));


% --------------------
% global setting for shoulder touch shoulder
PROXopts(3).name = 'SS';
PROXopts(3).submix(1).name = 'LSRS';
PROXopts(3).submix(1).pts1 = [1 2 3];
PROXopts(3).submix(1).pts2 = [7 2 1];
PROXopts(3).submix(1).touchnum = 9;
PROXopts(3).submix(2).name = 'RSLS';
PROXopts(3).submix(2).pts1 = [1 2 7];
PROXopts(3).submix(2).pts2 = [3 2 1];
PROXopts(3).submix(2).touchnum = 10;

PROXopts(3).K = [1 1 1 1 1 1];
PROXopts(3).pa = [0 1 2 3 4 5];
PROXopts(3).co = [2 1 2 5 6 5];
PROXopts(3).faceid = [1 6];

PROXopts(3).color = {'g','g','y','y','g','g'};

% Original labeling:
% 1. Top Head 2. Neck 3. Shoulder
% 4. Shoulder 5. Neck 6. Top Head
% After Transformation:
% 1. Head 2. Shoulder
% 3. Shoulder 4. Head
I = [1   1   2 3 4 5 6   6];
J = [1   2   2 3 4 5 5   6];
A = [1/2 1/2 1 1 1 1 1/2 1/2];
PROXopts(3).trans = full(sparse(I,J,A,6,6));

% For pose estimation evaluation
% 1. Head 2. Shoulder
% 3. Shoulder 4. Head
I = [1 2 3 4];
J = [1 3 4 6];
A = [1 1 1 1];
PROXopts(3).transback = full(sparse(I,J,A,4,6));


% --------------------
% global setting for hand touch baby torso
PROXopts(4).name = 'HBT';
PROXopts(4).submix(1).name = 'LHBT';
PROXopts(4).submix(1).pts1 = [1 2 3 4 5 6];
PROXopts(4).submix(1).pts2 = [2 1];
PROXopts(4).submix(1).touchnum = 11;
PROXopts(4).submix(2).name = 'RHBT';
PROXopts(4).submix(2).pts1 = [1 2 7 8 9 10];
PROXopts(4).submix(2).pts2 = [2 1];
PROXopts(4).submix(2).touchnum = 12;

PROXopts(4).K = [4 4 4 4 4 4 4 4 4 4];
PROXopts(4).pa = [0 1 2 3 4 5 6 7 8 9];
PROXopts(4).co = [2 1 2 3 4 5 6 7 10 9];
PROXopts(4).faceid = [1 10];

PROXopts(4).color = {'g','g','y','r','r','b','b','c','g','g'};

% Original labeling:
% 1. Top Head 2. Neck 3. Shoulder 4. Elbow 5. Wrist 6. Hand
% 7. Neck 8. Top Head
% After Transformation:
% 1. Head 2. Neck 3. Shoulder 4. Upp Arm 5. Elbow 6. Low Arm 7. Wrist 8. Hand
% 9. Neck 10. Head
I = [1   1   2 3 4   4   5 6   6   7 8 9 10  10];
J = [1   2   2 3 3   4   4 4   5   5 6 7 7   8];
A = [1/2 1/2 1 1 1/2 1/2 1 1/2 1/2 1 1 1 1/2 1/2];
PROXopts(4).trans = full(sparse(I,J,A,10,8));

% For pose estimation evaluation
% 1. Head 2. Shoulder 3. Elbow 4. Wrist
% 5. Head
I = [1 2 3 4 5];
J = [1 3 5 7 10];
A = [1 1 1 1 1];
PROXopts(4).transback = full(sparse(I,J,A,5,10));


% --------------------
% global setting for hand touch elbow
PROXopts(5).name = 'HE';
PROXopts(5).submix(1).name = 'LHLE';
PROXopts(5).submix(1).pts1 = [1 2 3 4 5 6];
PROXopts(5).submix(1).pts2 = [4 3 2 1];
PROXopts(5).submix(1).touchnum = 13;
PROXopts(5).submix(2).name = 'LHRE';
PROXopts(5).submix(2).pts1 = [1 2 3 4 5 6];
PROXopts(5).submix(2).pts2 = [8 7 2 1];
PROXopts(5).submix(2).touchnum = 14;
PROXopts(5).submix(3).name = 'RHLE';
PROXopts(5).submix(3).pts1 = [1 2 7 8 9 10];
PROXopts(5).submix(3).pts2 = [4 3 2 1];
PROXopts(5).submix(3).touchnum = 15;
PROXopts(5).submix(4).name = 'RHRE';
PROXopts(5).submix(4).pts1 = [1 2 7 8 9 10];
PROXopts(5).submix(4).pts2 = [8 7 2 1];
PROXopts(5).submix(4).touchnum = 16;

PROXopts(5).K = [1 1 1 1 1 1 1 1 1 1 1 1 1];
PROXopts(5).pa = [0 1 2 3 4 5 6 7 8 9 10 11 12];
PROXopts(5).co = [2 1 2 3 4 5 6 7 10 11 12 13 12];
PROXopts(5).faceid = [1 13];

PROXopts(5).color = {'g','g','y','r','r','b','b','c',...
                      'r','r','y','g','g'};
                        
% Original labeling:
% 1. Top Head 2. Neck 3. Shoulder 4. Elbow 5. Wrist 6. Hand
% 7. Elbow 8. Shoulder 9. Neck 10. Top Head
% After Transformation:
% 1. Head 2. Neck 3.Shoulder 4. Upp Arm 5. Elbow 6. Low Arm 7. Wrist 8. Hand
% 9. Elbow 10. Upp Arm 11. Shoulder 12. Neck 13. Head
I = [1   1   2 3 4   4   5 6   6   7 8 9 10  10  11 12 13  13];
J = [1   2   2 3 3   4   4 4   5   5 6 7 7   8   8  9  9   10];
A = [1/2 1/2 1 1 1/2 1/2 1 1/2 1/2 1 1 1 1/2 1/2 1  1  1/2 1/2];
PROXopts(5).trans = full(sparse(I,J,A,13,10));

% For pose estimation evaluation
% 1. Head 2. Shoulder 3. Elbow 4. Wrist
% 5. Elbow 6. Shoulder 7. Head
I = [1 2 3 4 5 6  7];
J = [1 3 5 7 9 11 13];
A = [1 1 1 1 1 1  1];
PROXopts(5).transback = full(sparse(I,J,A,7,13));


% --------------------
% global setting for elbow touch shoulder
PROXopts(6).name = 'ES';
PROXopts(6).submix(1).name = 'LELS';
PROXopts(6).submix(1).pts1 = [1 2 3 4];
PROXopts(6).submix(1).pts2 = [3 2 1];
PROXopts(6).submix(1).touchnum = 17;
PROXopts(6).submix(2).name = 'LERS';
PROXopts(6).submix(2).pts1 = [1 2 3 4];
PROXopts(6).submix(2).pts2 = [7 2 1];
PROXopts(6).submix(2).touchnum = 18;
PROXopts(6).submix(3).name = 'RELS';
PROXopts(6).submix(3).pts1 = [1 2 7 8];
PROXopts(6).submix(3).pts2 = [3 2 1];
PROXopts(6).submix(3).touchnum = 19;
PROXopts(6).submix(4).name = 'RERS';
PROXopts(6).submix(4).pts1 = [1 2 7 8];
PROXopts(6).submix(4).pts2 = [7 2 1];
PROXopts(6).submix(4).touchnum = 20;

PROXopts(6).K = [1 1 1 1 1 1 1 1];
PROXopts(6).pa = [0 1 2 3 4 5 6 7];
PROXopts(6).co = [2 1 2 3 4 7 8 7];
PROXopts(6).faceid = [1 8];

PROXopts(6).color = {'g','g','y','r','r','y','g','g'};

% Original labeling:
% 1. Top Head 2. Neck 3. Shoulder 4. Elbow
% 5. Shoulder 6. Neck 7. Top Head
% After Transformation:
% 1. Head 2. Neck 3. Shoulder 4. Upp Arm 5. Elbow
% 6. Shoulder 7. Neck 8. Head
I = [1   1   2 3 4   4   5 6 7 8   8];
J = [1   2   2 3 3   4   4 5 6 6   7];
A = [1/2 1/2 1 1 1/2 1/2 1 1 1 1/2 1/2];
PROXopts(6).trans = full(sparse(I,J,A,8,7));

% For pose estimation evaluation
% 1. Head 2. Shoulder 3. Elbow
% 4. Shoulder 5. Head
I = [1 2 3 4 5];
J = [1 3 5 6 8];
A = [1 1 1 1 1];
PROXopts(6).transback = full(sparse(I,J,A,5,8));
