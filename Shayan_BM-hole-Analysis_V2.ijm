input = getDirectory("Input directory");
Dialog.create("Naming");
Dialog.addString("File suffix: ", ".nd2", 5);
Dialog.addString("Date", "210301");
Dialog.addString("timepoint", "24hrs");
Dialog.addString("Experiment", "BB94");
Dialog.show();
suffix = Dialog.getString();
Date = Dialog.getString();; 
TP = Dialog.getString();;;
Exp = Dialog.getString();;;; 
targetD= input+Date+"_Image-Files"+File.separator;
File.makeDirectory(targetD);
targetD2= input+Date+"_Data-Files"+File.separator;
File.makeDirectory(targetD2);
TLpath=File.openDialog("Open the timelapse file");open(TLpath);
SaveName3=Date+Exp+TP
processFolder(input);
 
function processFolder(input) {
    list = getFileList(input);
    for (i = 0; i < list.length; i++) {
        if(File.isDirectory(list[i]))
            processFolder("" + input + list[i]);
        if(endsWith(list[i], suffix))
            processFile(input, list[i]);
    }
}
 
function processFile(input, file) {
    // do the processing here by replacing
    // the following two lines by your own code
          print("Processing: " + input + file);
    //run("Bio-Formats Importer", "open=" + input + file + " color_mode=Default view=Hyperstack stack_order=XYCZT");
    open(input + file);SaveName2=getTitle();SaveName=replace(SaveName2,".nd2","");rename(SaveName);SNSub=substring(SaveName2,0,1);
selectWindow(SaveName);run("Split Channels");
selectWindow("C3-"+SaveName);rename("Col4");
waitForUser("Select top and bottom for MIP formation and input in the next window");
Dialog.create("Z-stack selection");
Dialog.addString("Bottom ", "1");
Dialog.addString("Top", "50");
Dialog.show();
Bot= Dialog.getString();
Top = Dialog.getString();; 
run("Z Project...", "start=Bot stop=Top projection=[Max Intensity]"); selectWindow("MAX_Col4");
saveAs("Tiff", targetD+"MAX_"+SaveName3+"_Col4");rename("Max_Col4");
selectWindow("Max_Col4");run("Unsharp Mask...", "radius=15 mask=0.60");saveAs("Tiff", targetD+"Fil-MAX_"+SaveName3+"_"+SNSub+"_Col4");rename("For-Mask");

run("Set Measurements...", "area mean standard min bounding fit shape feret's median area_fraction limit redirect=None decimal=3");
selectWindow("For-Mask");setTool("freehand");setAutoThreshold("Li");
waitForUser("Please create an ROI");
run("ROI Manager...");
roiManager("Add");
run("Analyze Particles...", "size=1.50-Infinity show=Masks display exclude include summarize");
selectWindow("Mask of For-Mask");saveAs("Tiff", targetD+"Holes_"+SaveName3+"_"+SNSub+"_Col4");close();

selectWindow("Results");Table.rename("Results", SaveName3+"_"+SNSub+"_Holes-IND");
Table.save(targetD2+SaveName3+"_"+SNSub+"_Holes-IND.csv");selectWindow(SaveName3+"_"+SNSub+"_Holes-IND"); close();
selectWindow("Summary");
Table.save(targetD2+SaveName3+"_"+SNSub+"_Holes-SUM.csv");close();Table.deleteRows(0, 15, "Summary");

roiManager("Delete");run("Close All");
}
