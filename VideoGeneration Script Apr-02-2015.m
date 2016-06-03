
% Example Linux script to batch generate correctly sized thumbnail stacks of registered coronal sections of a set of brain 
% These thumbnail stecks are in turn is used to generate fly-through video
% by a separate matlab code called FlyThroughVideo.m

pmd_F_ids = [1974 2020 2021 2042 2043 2050 2051];
pmd_IHC_ids = [2014 2015 ];

for i=pmd_F_ids
    fprintf(1,'cp /home/ferenc/zvideos/zStackAlignTxtFiles/PMD%d_F_XForm.txt .\n',i);
    fprintf(1,'./ApplyTFormTIF_db PMD%d_F_XForm.txt  PMD%d_F_PNGS\n',i,i);
end;
for i=pmd_IHC_ids
    fprintf(1,'cp /home/ferenc/zvideos/zStackAlignTxtFiles/PMD%d_IHC_XForm.txt .\n',i);
    fprintf(1,'./ApplyTFormTIF_db PMD%d_IHC_XForm.txt  PMD%d_IHC_PNGS\n',i,i);
end;

cd /data1/PORTAL_VIDEOS/

cp /home/ferenc/zvideos/zStackAlignTxtFiles/PMD1974_F_XForm.txt .
./ApplyTFormTIF_db PMD1974_F_XForm.txt  PMD1974_F_PNGS
cp /home/ferenc/zvideos/zStackAlignTxtFiles/PMD2020_F_XForm.txt .
./ApplyTFormTIF_db PMD2020_F_XForm.txt  PMD2020_F_PNGS
cp /home/ferenc/zvideos/zStackAlignTxtFiles/PMD2021_F_XForm.txt .
./ApplyTFormTIF_db PMD2021_F_XForm.txt  PMD2021_F_PNGS
cp /home/ferenc/zvideos/zStackAlignTxtFiles/PMD2042_F_XForm.txt .
./ApplyTFormTIF_db PMD2042_F_XForm.txt  PMD2042_F_PNGS
cp /home/ferenc/zvideos/zStackAlignTxtFiles/PMD2043_F_XForm.txt .
./ApplyTFormTIF_db PMD2043_F_XForm.txt  PMD2043_F_PNGS
cp /home/ferenc/zvideos/zStackAlignTxtFiles/PMD2050_F_XForm.txt .
./ApplyTFormTIF_db PMD2050_F_XForm.txt  PMD2050_F_PNGS
cp /home/ferenc/zvideos/zStackAlignTxtFiles/PMD2051_F_XForm.txt .
./ApplyTFormTIF_db PMD2051_F_XForm.txt  PMD2051_F_PNGS
cp /home/ferenc/zvideos/zStackAlignTxtFiles/PMD2014_IHC_XForm.txt .
./ApplyTFormTIF_db PMD2014_IHC_XForm.txt  PMD2014_IHC_PNGS
cp /home/ferenc/zvideos/zStackAlignTxtFiles/PMD2015_IHC_XForm.txt .
./ApplyTFormTIF_db PMD2015_IHC_XForm.txt  PMD2015_IHC_PNGS

