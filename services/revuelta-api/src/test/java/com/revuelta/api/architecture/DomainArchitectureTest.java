package com.revuelta.api.architecture;

import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.noClasses;

import com.tngtech.archunit.core.domain.JavaClasses;
import com.tngtech.archunit.core.importer.ClassFileImporter;
import org.junit.jupiter.api.Test;

class DomainArchitectureTest {

    private final JavaClasses productionClasses = new ClassFileImporter()
            .importPackages("com.revuelta.api");

    @Test
    void domainMustNotDependOnApplicationInfrastructureOrInterfaces() {
        noClasses()
                .that().resideInAPackage("..domain..")
                .should().dependOnClassesThat().resideInAnyPackage(
                        "..application..",
                        "..infrastructure..",
                        "..interfaces.."
                )
                .check(productionClasses);
    }

    @Test
    void domainMustRemainIndependentFromFrameworksAndPersistenceApis() {
        noClasses()
                .that().resideInAPackage("..domain..")
                .should().dependOnClassesThat().resideInAnyPackage(
                        "org.springframework..",
                        "jakarta.persistence..",
                        "com.fasterxml.jackson.."
                )
                .check(productionClasses);
    }
}
