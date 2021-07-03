function TwoVar(VarInd,Uinput,Eq)
%solve equation and output graphic SolArrays

%-------------------Obtain data and process it:
%obtain all parameters from equation
Parameters=symvar(Eq);

%Build coefficent vector
Coeff=1:length(Parameters);
Coeff(VarInd)=[];

%initliaize ArrInd - index that will point to array in parameters if exists
ArrInd=[];

%create Coeffs and ArrInd
for i=Coeff
    if length(str2num(Uinput{i}))>1
        ArrInd=i;
    else
        eval(sprintf('%s=str2num(Uinput{i});',Parameters{i}));
    end
end

%find equation variable names
VarNames=[Parameters(VarInd(1));Parameters(VarInd(2))]; %cell array of strings

%create variable in workspace
for i=1:2
    eval(sprintf('%s = sym(''%s'');',VarNames{i},VarNames{i}));
end

%---------------------Create figure and axes to work about
fFig=figure('Name','EqSol figure');
fAxes=axes('Parent',fFig,'outerposition',[0,0.1,1,0.9]);
grid(fAxes,'on');
hold(fAxes,'on'); %is here for the case that vector has input array and multiple plots need drawing
LtxVar1=latex(eval(VarNames{1})); %create latex text out of variables
LtxVar2=latex(eval(VarNames{2}));
ylabel(fAxes,LtxVar1); %this order here is default
xlabel(fAxes,LtxVar2);
%add title
title(fAxes,[LtxVar1  ' vs ' LtxVar2]);

%------------------solve equation

switch length(ArrInd)
    
    case 0 %no vector input from user
        
        %compute equation
        SolArr=eval(sprintf('solve(%s,%s)',Eq,VarNames{1})); %chooses the first one to compute for (default)
        SolCell={SolArr}; %to accomidiate for callback (needs to work with both case 0 and case 1)
        
        if isempty(SolArr) %if equation cant be solved
            errordlg('Cant solve this','EqSolArr Manager');
            close fFig
            return
        end
        
        FstSol=SolArr(1); %default to first SolArrays
        
        %plots
        fplot(fAxes,FstSol);     
    case 1 %User has inputed array in one of the parameters
        
        %create numeric array to loop about
        ArrCoeff=str2num(Uinput{ArrInd}); %find the array coefficent - numeric array
        SolCell=[]; %Initalize SolCell - array of SolArrays 
        for j=1:length(ArrCoeff)
            
            eval(sprintf('%s=ArrCoeff(j);',Parameters{ArrInd})); %create ArrCoeff named variable with value ArrCoeff(j)
            
            %compute equation
            SolArr=eval(sprintf('solve(%s,%s)',Eq,VarNames{1})); %chooses the first one to compute for (default)
            SolCell{j}=SolArr; %cell array of SolArrayss
            
            if isempty(SolArr) %if equation cant be solved
                errordlg('Cant solve this','EqSolArr Manager');
                close fFig
                return
            end
            
            FstSol=SolArr(1); %default to first SolArrays
            
            %plot
            fplot(fAxes,FstSol);
        end
        
        %add legend
        ArrCoeff=(ArrCoeff(:)); %garuntee column vector
        legend(fAxes,strcat([Parameters{ArrInd},'='],cellstr(num2str(ArrCoeff))),'Interpreter','latex',...
            'AutoUpdate','off');
end

hold(fAxes,'off'); %turn hold off

%---------------------introduce buttons to figure

%create SolArray switch button. stores array of indexing in this buttons
%userdata 1:length(SolArr)
SwtSol=uicontrol('parent',fFig,'Style', 'pushbutton','units','normalized','Position',[0.6 0.005 0.2 0.09],...
    'Callback',{@SolArrSwitchCB,SolCell}); %SolCell contains numel(ArrInd) cells, and in each one is SolArr
SwtSol.UserData=1:length(SolArr);
SwtSol.String=['Solution ',num2str(SwtSol.UserData(1)),'/',num2str(max(SwtSol.UserData))]; %initalize

%create flip button
uicontrol('parent',fFig,'Style', 'pushbutton', 'String', 'Flip Axes','units','normalized','Position',[0.8 0.005 0.2 0.09],...
    'Callback',@FlipAxesCB);

end

%---------------------Callbacks
function FlipAxesCB(src,~)
%changes current axes view
fFig=src.Parent;
fAxes=fFig.CurrentAxes;
fAxes.View=fAxes.View+[90,180];
end

function SolArrSwitchCB(src,~,SolCell)
%shift SolArrays vector, update graph and button text
src.UserData=circshift(src.UserData,-1); %stores an array 1:length(SolCell), pointer on first value

fFig=src.Parent;
fAxes=fFig.CurrentAxes;

%clear of old plots and reset coloring order
PrevPlots=findobj(fAxes,'Type','FunctionLine');
delete(PrevPlots)
fAxes.ColorOrderIndex=1; %reset colors to start

%plot new ones
hold(fAxes,'on'); %turn hold on
for j=1:length(SolCell) %run on cell array
    SolArr=SolCell{j}; %Obtain SolArr j from Cell Array
    fplot(fAxes,SolArr(src.UserData(1))); %plot solution SolArr(src.UserData...)
    
    src.String=['Solution ',num2str(src.UserData(1)),'/',num2str(max(src.UserData))]; %initalize
end

hold(fAxes,'off'); %turn hold off
end