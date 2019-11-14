function [guess, value, iterations] = optim3steps_john(func, init_guess, step_major, step_minor, step_miniscule, max_iterations, varargin)
%
%
% OPTIM3STEPS: An iterative procedure adjusting the input guess value to a
% function until the output value from the function reaches a maximum.
% 
%
%  Syntax:
%    [GUESS, VALUE, ITERATIONS] = OPTIM2STEPS(FUNC, INIT_GUESS, STEP_MAJOR, STEP_MINOR, MAX_ITERATIONS, ...)
%
%  Description:
%      Runs function "func" with an initial guess value ("init_guess").
%   Takes the output value from "func", and compares the value
%   ("next_value") to the previous output value ("value"). The input guess
%   value ("next_guess") is then adjusted by either a major or minor step
%   depending on the magnitude of the difference between "value" and
%   "next_value", and the function is re-run. This is an iterative
%   procedure to find the input guess value that leads to a maximum output
%   value. Gives the user the option to alter the initial guess value
%   before continuing with the iterations.
%
%  Notes:
%
%  Examples:
%    func = @(x)(x^2)
%    init_guess = 1
%    step_major = 0.1
%    step_minor = 0.01
%    max_iterations = 100
%    [guess, value, iterations] = optim2steps(func, init_guess, step_major, step_minor, max_iterations)
%
%  See also:
%
%  Authors:
%    Joan Pau Beltran  <joanpau.beltran@socib.cat>
%  Edited by Krissy Reeve <kreeve@socib.es> on 01/06/2016

%  Copyright (C) 2015
%  ICTS SOCIB - Servei d'observacio i prediccio costaner de les Illes Balears.
%  <http://www.socib.es>
%
%  This program is free software: you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published by
%  the Free Software Foundation, either version 3 of the License, or
%  (at your option) any later version.
%
%  This program is distributed in the hope that it will be useful,
%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with this program.  If not, see <http://www.gnu.org/licenses/>.

  guess = init_guess;
  value = func(guess, varargin{:});
  step = step_major;
  ANS = questdlg('Do you want to alter the initial guess?','Change initial guess','yes','no','no');
  if strcmpi(ANS,'yes')==1
    guess = str2double(inputdlg('alter initial guess','alter initial guess',1,{(num2str(guess))}));
    value = func(guess, varargin{:});
    step = step_major;
  end
  clear ANS
  %disp(['INITIAL GUESS = ', sprintf('%1.6f',init_guess(n))])
  disp(['INITIAL GUESS = ', sprintf('%1.6f', guess)])
  disp(['INITIAL VALUE =    ',num2str(value)])
  iter_monitor = 1;
  for iterations = 1:max_iterations
      next_guess = guess + step;
      next_value = func(next_guess, varargin{:});

    
%     figure (3)
%     plot(next_guess, next_value, '.m', 'markersize', 16); hold on
    disp(['next_guess = ' num2str(next_guess,8) 9 'value = ' num2str(value) 9 'next_value = ' num2str(next_value) 9 'diff = ' num2str(next_value - value) 9 'iter_monitor = ' num2str(iter_monitor)])
    whos

    if next_value > value
      value = next_value;
      guess = next_guess;
      iter_monitor = 2;
      
    elseif (iter_monitor == 1)
        guess = next_guess - step;
        value = func(guess, varargin{:});
        step = -step;
        iter_monitor = 2;
        
    elseif (abs(step) == abs(step_major))
      guess = next_guess - step;
      value = func(guess, varargin{:});
      step = step_minor;
      iter_monitor = 1;
      
    elseif (abs(step) == abs(step_minor))
      guess = next_guess - step;
      value = func(guess, varargin{:});
      step = step_miniscule;
      iter_monitor = 1;
      
    else
      guess = next_guess - step;
      value = func(guess, varargin{:});
      break
    end

  end
  
%     for iterations = 1:max_iterations
%       next_guess = guess + step;
%       next_value = func(next_guess, varargin{:});
% 
%     
% %     figure (3)
% %     plot(next_guess, next_value, '.m', 'markersize', 16); hold on
%     disp([num2str(next_guess,8), ' ', num2str(next_value), ' ', num2str(next_value - value)])
%     
%     if next_value > value
%       value = next_value;
%       guess = next_guess;
%     elseif (step == step_major)
%       step = -step_major;
%     elseif (step == -step_major)
%       step = step_minor;
%     elseif (step == step_minor)
%       step = -step_minor;
%     elseif (step == -step_minor) 
%       step = step_miniscule;
%     elseif (step == step_miniscule) 
%        step = -step_miniscule; 
%     else
%       break
%     end
%     if iterations==1
%         ANS = questdlg('Do you want to alter the initial guess?','Change initial guess','yes','no','no');
%         if strcmpi(ANS,'yes')==1
%             guess = str2double(inputdlg('alter initial guess','alter initial guess',1,{(num2str(guess))}));
%             value = func(guess, varargin{:});
%             step = step_major;
%         end
%         clear ANS
%     end
%   end
end