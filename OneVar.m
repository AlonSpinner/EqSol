function OneVar(app,VarInd,Uinput,Eq)
%solve equation and output to text area

%obtain all Paramters from equation
Parameters=symvar(Eq);

%Build Coefficent vector
Coeff=1:length(Parameters);
Coeff(VarInd)=[];

%Create double variables who have the names of the coefficents and the values give by user
for i=Coeff
    eval(sprintf('%s=str2double(Uinput{i});',Parameters{i}));
end

%create equation variable in workspace as a symbolic variable with its given name
VarName=Parameters{VarInd};
eval(sprintf('syms %s',VarName));

%compute equation - solve(Equation,variable name)
Sol=eval(sprintf('solve(%s,%s)',str2sym(Eq),VarName));

%print answer - a tricky buissness
Sol=round(double(Sol),3); %turn solution to double vector array and round it
Sol=cellstr(num2str(Sol)); %turn Sol to a cell array of strings
Sol{1,1}=[VarName,'=',Sol{1,1}]; %input into SOl's first string [varname=first answer]
app.SolutionTextArea.Value=Sol; %display solution

end