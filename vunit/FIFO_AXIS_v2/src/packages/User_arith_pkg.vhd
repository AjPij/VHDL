
-- Package declaration
package User_arith_pkg is
    
    component User_arith_component is
    end component User_arith_component;

    function LogBase2Func( arg : in integer)
        return integer;
    
    
end package User_arith_pkg;

-- Package body 
package body User_arith_pkg is
        function LogBase2Func( arg: in integer )        
        return integer is
            variable exp_temp : integer := 0;
            variable arg_temp : integer := 0;
        begin 
            arg_temp := arg;
            for i in 0 to 64 loop
                if( arg_temp  /= 0 )then
                    arg_temp := arg_temp / 2; -- synth as shift right logic, hopefully
                    exp_temp := exp_temp + 1;
                else
                    exp_temp := exp_temp;
                end if;                        
            end loop;
        return exp_temp; 
    end function logBase2Func;  
end package body User_arith_pkg;

