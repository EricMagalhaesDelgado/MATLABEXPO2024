function compCustomizationV2(jsBackDoor, comp, varargin)

    arguments
        jsBackDoor {isa(jsBackDoor, 'matlab.ui.control.HTML')}
        comp
    end

    arguments (Repeating)
        varargin
    end

    % nargin validation
    if nargin <= 2
        error('At least one Name-Value parameters must be passed to the function.')
    elseif mod(nargin-2, 2)
        error('Name-value parameters must be in pairs.')
    end

    warning('off', 'MATLAB:structOnObject')
    warning('off', 'MATLAB:ui:javaframe:PropertyToBeRemoved')
    
    % main variables
    releaseVersion = version('-release');
    releaseYear    = str2double(releaseVersion(1:4));

    if releaseYear <= 2022
        compTag = struct(comp).Controller.ProxyView.PeerNode.Id;
    else
        compTag = struct(comp).Controller.ViewModel.Id;
    end

    % customizations...
    switch class(comp)
    %---------------------------------------------------------------------%
        case {'matlab.ui.container.ButtonGroup',  ...
              'matlab.ui.container.CheckBoxTree', ...
              'matlab.ui.container.Tree'}
            propStruct = InputParser({'backgroundColor', ...
                                      'borderRadius', 'borderWidth', 'borderColor', 'padding'}, varargin{:});

        case 'matlab.ui.container.Panel'
            propStruct = InputParser({'padding', 'backgroundColor'}, varargin{:});

        case 'matlab.ui.container.GridLayout'
            propStruct = InputParser({'backgroundColor', 'borderRadius', 'borderBottomLeftRadius', 'borderBottomRightRadius', 'borderTopLeftRadius', 'borderTopRightRadius'}, varargin{:});

        case 'matlab.ui.container.TabGroup'
            propStruct = InputParser({'backgroundColor', 'backgroundHeaderColor', 'transparentHeader', ...
                                      'borderRadius', 'borderWidth', 'borderColor',                    ...
                                      'fontFamily', 'fontStyle', 'fontWeight', 'fontSize', 'color'}, varargin{:});

        case {'matlab.ui.control.Button',           ...
              'matlab.ui.control.DropDown',         ...
              'matlab.ui.control.EditField',        ...
              'matlab.ui.control.ListBox',          ...
              'matlab.ui.control.NumericEditField', ...
              'matlab.ui.control.StateButton'}
            propStruct = InputParser({'borderRadius', 'borderWidth', 'borderColor'}, varargin{:});

        case 'matlab.ui.control.TextArea'
            propStruct = InputParser({'backgroundColor',                            ...
                                      'borderRadius', 'borderWidth', 'borderColor', ...
                                      'textAlign'}, varargin{:});

        case 'matlab.ui.control.Label'
            propStruct = InputParser({'textAlign'}, varargin{:});

        case 'matlab.ui.control.CheckBox'
            propStruct = InputParser({'backgroundColor',                            ...
                                      'borderRadius', 'borderWidth', 'borderColor'}, varargin{:});

        case 'matlab.ui.control.Table'
            propStruct = InputParser({'backgroundColor', 'backgroundHeaderColor',   ...
                                      'borderRadius', 'borderWidth', 'borderColor', ...
                                      'textAlign', 'paddingTop', 'fontFamily', 'fontStyle', 'fontWeight', 'fontSize', 'color'}, varargin{:});
        otherwise
            error('ccTools does not cover the customization of ''%s'' class properties.', class(comp))
    end


    % JS
    pause(.001)
    for ii = 1:numel(propStruct)
        sendEventToHTMLSource(jsBackDoor, "compCustomization", struct("Class",    class(comp),         ...
                                                                      "DataTag",  compTag,             ...
                                                                      "Property", propStruct(ii).name, ...
                                                                      "Value",    propStruct(ii).value));
    end
end


%-------------------------------------------------------------------------%
function propStruct = InputParser(propList, varargin)    
    p = inputParser;
    d = [];

    for ii = 1:numel(propList)
        switch(propList{ii})
            % Window
            case 'windowMinSize';           addParameter(p, 'windowMinSize',           d)

            % BackgroundColor
            case 'backgroundColor';         addParameter(p, 'backgroundColor',         d)
            case 'backgroundHeaderColor';   addParameter(p, 'backgroundHeaderColor',   d)
            case 'transparentHeader';       addParameter(p, 'transparentHeader',       d)

            % Border
            case 'padding';                 addParameter(p, 'padding',                 d)
            case 'borderRadius';            addParameter(p, 'borderRadius',            d)
            case 'borderBottomLeftRadius';  addParameter(p, 'borderBottomLeftRadius',  d)
            case 'borderBottomRightRadius'; addParameter(p, 'borderBottomRightRadius', d)
            case 'borderTopLeftRadius';     addParameter(p, 'borderTopLeftRadius',     d)
            case 'borderTopRightRadius';    addParameter(p, 'borderTopRightRadius',    d)
            case 'borderWidth';             addParameter(p, 'borderWidth',             d)
            case 'borderColor';             addParameter(p, 'borderColor',             d)

            % Font
            case 'textAlign';               addParameter(p, 'textAlign',               d)
            case 'paddingTop';              addParameter(p, 'paddingTop',              d)
            case 'fontFamily';              addParameter(p, 'fontFamily',              d)
            case 'fontStyle';               addParameter(p, 'fontStyle',               d)
            case 'fontWeight';              addParameter(p, 'fontWeight',              d)
            case 'fontSize';                addParameter(p, 'fontSize',                d)
            case 'color';                   addParameter(p, 'color',                   d)
        end
    end
            
    parse(p, varargin{:});

    propStruct = struct('name', {}, 'value', {});
    propName   = setdiff(p.Parameters, p.UsingDefaults);

    for ll = 1:numel(propName)
        propValue = p.Results.(propName{ll});

        if ismember(propName{ll}, {'backgroundColor', 'backgroundHeaderColor', 'borderColor', 'color'})
            if isnumeric(p.Results.(propName{ll}))
                propValue = ccTools.fcn.rgb2hex(propValue);
            else
                propValue = char(propValue);
            end
        end

        propStruct(ll) = struct('name',  propName{ll}, ...
                                'value', propValue);
    end
end