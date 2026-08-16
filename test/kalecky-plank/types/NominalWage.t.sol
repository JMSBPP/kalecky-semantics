// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {BuildOptions,Dependency,PlankDeployer} from "plank-foundry-deployer/PlankDeployer.sol";
import {console2} from "forge-std/console2.sol";


struct NominalWage{
        uint256 val;
}
interface INominalWageSetter {
    function set_wage(NominalWage memory) external returns(NominalWage memory);
}


contract NominalWageTest is Test, PlankDeployer {
    INominalWageSetter wage_setter;

    function setUp() public {
	BuildOptions memory opts;
	opts.backend = "sona";
	Dependency[] memory deps = new Dependency[](2);
 
	deps[0] = Dependency("std", "lib/plank-monorepo/std/");
	deps[1] = Dependency("types","kalecky-plank/");
	opts.dependencies = deps;

	wage_setter = INominalWageSetter(
					 plankDeployFFI(
							"kalecky-plank/test/NominalWageSetter.plk",
							opts
					 )
	);
	
    }

    function test__unit__setWage() public {
	console2.log("El gobierno fijo un salario minimo de 1800000 COP por mes");
	NominalWage memory nom_wage = wage_setter.set_wage(NominalWage(1_800_000));
	console2.log(nom_wage.val);
    }
}
