
entity attr is
end entity;

architecture test of attr is
	subtype myint is integer range 0 to 7;
	--variable int:myint;
	signal pow:integer;
begin
	pow <= myint'high;
end architecture;
		