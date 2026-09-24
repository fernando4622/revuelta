package com.revuelta.api.contract;

import static org.junit.jupiter.api.Assertions.assertEquals;

import com.revuelta.api.interfaces.rest.AuthController;
import com.revuelta.api.interfaces.rest.CirculationController;
import com.revuelta.api.interfaces.rest.ContainerController;
import com.revuelta.api.interfaces.rest.QrController;
import java.io.InputStream;
import java.lang.reflect.Method;
import java.lang.reflect.RecordComponent;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import org.junit.jupiter.api.Test;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.yaml.snakeyaml.Yaml;

class RestEndpointOpenApiContractTest {

    private static final Set<String> HTTP_METHODS = Set.of("get", "post", "put", "patch", "delete");
    private static final String API_PREFIX = "/api/v1";

    @Test
    void everyImplementedEndpointMustMatchExactlyOneOpenApiOperation() {
        assertEquals(openApiRoutes(), implementedRoutes());
    }

    @Test
    void publicResponseFieldsMustMatchTheDocumentedSchemas() {
        assertEquals(
                recordFields(AuthController.LoginResponse.class),
                openApiInlineResponseFields("/auth/login", "post", "200")
        );
        assertEquals(
                recordFields(ContainerController.ContainerResponse.class),
                openApiSchemaFields("Container")
        );
        assertEquals(
                recordFields(ContainerController.RegisteredContainerResponse.class),
                openApiSchemaFields("RegisteredContainer")
        );
        assertEquals(recordFields(QrController.OperationQrResponse.class), openApiSchemaFields("OperationQr"));
        assertEquals(recordFields(QrController.ResolveOperationQrResponse.class), openApiSchemaFields("ResolvedOperationQr"));
        assertEquals(recordFields(QrController.ResolveContainerQrResponse.class), openApiSchemaFields("ResolvedContainerQr"));
        assertEquals(recordFields(QrController.ContainerQrResponse.class), openApiSchemaFields("ContainerQr"));
        assertEquals(
                recordFields(CirculationController.CirculationResponse.class),
                openApiSchemaFields("Circulation")
        );
        assertEquals(recordFields(CirculationController.DeliveryResponse.class), openApiSchemaFields("Delivery"));
        assertEquals(recordFields(CirculationController.DeliveryPreviewResponse.class), openApiSchemaFields("DeliveryPreview"));
        assertEquals(recordFields(CirculationController.DeliveryContainerResponse.class), openApiSchemaFields("DeliveryContainer"));
        assertEquals(recordFields(CirculationController.DeliveryPolicyResponse.class), openApiSchemaFields("DeliveryPolicy"));
        assertEquals(
                recordFields(CirculationController.EventResponse.class),
                openApiSchemaFields("ContainerEvent")
        );
    }

    @Test
    void publicRequestFieldsMustMatchTheDocumentedSchemas() {
        assertEquals(
                recordFields(AuthController.LoginRequest.class),
                openApiInlineRequestFields("/auth/login", "post")
        );
        assertEquals(
                recordFields(ContainerController.RegisterContainerRequest.class),
                openApiInlineRequestFields("/containers", "post")
        );
        assertEquals(
                recordFields(ContainerController.ActivateRequest.class),
                openApiInlineRequestFields("/containers/{containerId}/activate", "post")
        );
        assertEquals(
                recordFields(CirculationController.DeliverRequest.class),
                openApiInlineRequestFields("/circulations", "post")
        );
        assertEquals(
                recordFields(CirculationController.DeliverRequest.class),
                openApiInlineRequestFields("/delivery-previews", "post")
        );
        assertEquals(recordFields(QrController.GenerateOperationQrRequest.class), openApiInlineRequestFields("/me/operation-qrs", "post"));
        assertEquals(recordFields(QrController.QrPayloadRequest.class), openApiInlineRequestFields("/operation-qr-resolutions", "post"));
        assertEquals(recordFields(QrController.QrPayloadRequest.class), openApiInlineRequestFields("/container-qr-resolutions", "post"));
        assertEquals(recordFields(QrController.RotateContainerQrRequest.class), openApiInlineRequestFields("/containers/{containerId}/qr-rotations", "post"));
    }

    private Set<Route> implementedRoutes() {
        Set<Route> routes = new HashSet<>();
        for (Class<?> controller : Set.of(
                AuthController.class, ContainerController.class, CirculationController.class, QrController.class
        )) {
            RequestMapping classMapping = controller.getAnnotation(RequestMapping.class);
            String prefix = firstPath(selectPaths(classMapping.path(), classMapping.value()));
            for (Method method : controller.getDeclaredMethods()) {
                addRoute(routes, prefix, method, "get", method.getAnnotation(GetMapping.class));
                addRoute(routes, prefix, method, "post", method.getAnnotation(PostMapping.class));
                addRoute(routes, prefix, method, "put", method.getAnnotation(PutMapping.class));
                addRoute(routes, prefix, method, "patch", method.getAnnotation(PatchMapping.class));
                addRoute(routes, prefix, method, "delete", method.getAnnotation(DeleteMapping.class));
            }
        }
        return routes;
    }

    private void addRoute(Set<Route> routes, String prefix, Method method, String httpMethod, Object mapping) {
        if (mapping == null) {
            return;
        }

        String[] paths;
        if (mapping instanceof GetMapping annotation) {
            paths = selectPaths(annotation.path(), annotation.value());
        } else if (mapping instanceof PostMapping annotation) {
            paths = selectPaths(annotation.path(), annotation.value());
        } else if (mapping instanceof PutMapping annotation) {
            paths = selectPaths(annotation.path(), annotation.value());
        } else if (mapping instanceof PatchMapping annotation) {
            paths = selectPaths(annotation.path(), annotation.value());
        } else if (mapping instanceof DeleteMapping annotation) {
            paths = selectPaths(annotation.path(), annotation.value());
        } else {
            throw new IllegalArgumentException("Unsupported mapping on " + method.getName());
        }
        String path = prefix + firstPath(paths);
        routes.add(new Route(httpMethod, path.substring(API_PREFIX.length())));
    }

    @SuppressWarnings("unchecked")
    private Set<Route> openApiRoutes() {
        Map<String, Object> document = openApiDocument();
        try {
            Map<String, Map<String, Object>> paths = (Map<String, Map<String, Object>>) document.get("paths");
            Set<Route> routes = new HashSet<>();
            paths.forEach((path, operations) -> operations.keySet().stream()
                    .filter(HTTP_METHODS::contains)
                    .map(method -> new Route(method, path))
                    .forEach(routes::add));
            return routes;
        } catch (Exception exception) {
            throw new IllegalStateException("Unable to inspect OpenAPI routes", exception);
        }
    }

    @SuppressWarnings("unchecked")
    private Set<String> openApiSchemaFields(String schemaName) {
        Map<String, Object> document = openApiDocument();
        Map<String, Object> components = (Map<String, Object>) document.get("components");
        Map<String, Map<String, Object>> schemas = (Map<String, Map<String, Object>>) components.get("schemas");
        Map<String, Object> schema = schemas.get(schemaName);
        Map<String, Object> properties = (Map<String, Object>) schema.get("properties");
        return properties.keySet();
    }

    @SuppressWarnings("unchecked")
    private Set<String> openApiInlineRequestFields(String path, String method) {
        Map<String, Object> operation = operation(path, method);
        Map<String, Object> requestBody = (Map<String, Object>) operation.get("requestBody");
        Map<String, Object> content = (Map<String, Object>) requestBody.get("content");
        Map<String, Object> mediaType = (Map<String, Object>) content.get("application/json");
        return schemaProperties(mediaType).keySet();
    }

    @SuppressWarnings("unchecked")
    private Set<String> openApiInlineResponseFields(String path, String method, String status) {
        Map<String, Object> operation = operation(path, method);
        Map<String, Object> responses = (Map<String, Object>) operation.get("responses");
        Map<String, Object> response = (Map<String, Object>) responses.get(status);
        Map<String, Object> content = (Map<String, Object>) response.get("content");
        Map<String, Object> mediaType = (Map<String, Object>) content.get("application/json");
        return schemaProperties(mediaType).keySet();
    }

    @SuppressWarnings("unchecked")
    private Map<String, Object> operation(String path, String method) {
        Map<String, Object> document = openApiDocument();
        Map<String, Map<String, Object>> paths = (Map<String, Map<String, Object>>) document.get("paths");
        return (Map<String, Object>) paths.get(path).get(method);
    }

    @SuppressWarnings("unchecked")
    private Map<String, Object> schemaProperties(Map<String, Object> mediaType) {
        Map<String, Object> schema = (Map<String, Object>) mediaType.get("schema");
        return (Map<String, Object>) schema.get("properties");
    }

    private Set<String> recordFields(Class<?> recordType) {
        return Arrays.stream(recordType.getRecordComponents())
                .map(RecordComponent::getName)
                .collect(java.util.stream.Collectors.toSet());
    }

    private Map<String, Object> openApiDocument() {
        try (InputStream source = getClass().getResourceAsStream("/openapi.yaml")) {
            return new Yaml().load(source);
        } catch (Exception exception) {
            throw new IllegalStateException("Unable to read OpenAPI contract", exception);
        }
    }

    private String firstPath(String[] paths) {
        return paths.length == 0 ? "" : paths[0];
    }

    private String[] selectPaths(String[] paths, String[] values) {
        return paths.length == 0 ? values : paths;
    }

    private record Route(String method, String path) {}
}
