--------------------------------------------------
# 0.1 PILOT SCOPE — INSTITUTION-SPECIFIC PRODUCT
--------------------------------------------------

IMPORTANT:

The first ReVuelta deployment is NOT a generic multi-campus,
multi-restaurant or multi-partner platform.

The prototype represents a single real-world pilot:

    ReVuelta
        ↓
    Instituto Tecnológico de Veracruz (ITVer)
        ↓
    Institutional cafeteria
        ↓
    Reusable container circulation

The entire first-version UX, terminology, navigation,
locations, messages and operational flows must reflect this
specific institutional context.

Do NOT design the product as if it already serves:

- multiple universities;
- multiple campuses;
- multiple cafeterias;
- independent restaurants;
- external commercial partners;
- multiple cities;
- multiple organizations.

Those may become future extensions, but they are NOT part of
the first prototype.

The first prototype should feel intentionally specific to ITVer.

This specificity is a product decision, not a limitation to hide.

--------------------------------------------------
# 0.2 INSTITUTIONAL CONTEXT
--------------------------------------------------

The primary environment is:

    Instituto Tecnológico de Veracruz

The physical environment is:

    the institutional cafeteria

The primary user population is:

    students and members of the institutional community
    participating in the cafeteria container program.

The primary operational counterpart is:

    the cafeteria staff responsible for handing out
    and receiving ReVuelta containers.

The ReVuelta team operates and supervises the pilot.

Therefore the system has three operational perspectives:

    1. Student / user
    2. Cafeteria staff
    3. ReVuelta operations

Do not refer to the cafeteria as a generic "restaurant partner"
inside the primary student experience.

Prefer:

    "Cafetería"

    "Cafetería del Instituto"

    or the institutionally correct official name,

depending on the confirmed terminology used by the project.

Do not display generic terminology such as:

    "Partner"
    "Restaurant"
    "Vendor"
    "Merchant"
    "Store"

to students unless the real institutional operation
actually uses that terminology.

--------------------------------------------------
# 0.3 LOCATION MODEL
--------------------------------------------------

The first version operates within a single institutional site.

Do not introduce a generic location hierarchy such as:

    Organization
      → Campus
          → Building
              → Restaurant
                  → Pickup point

unless required by the existing domain specification.

For the pilot, the relevant physical context is simply:

    Instituto Tecnológico de Veracruz
        ↓
    Cafetería
        ↓
    ReVuelta return point

If the real cafeteria has a specific official name,
use that name consistently throughout the product.

If the exact name has not yet been formally established,
use "Cafetería del Instituto" rather than inventing a name.

--------------------------------------------------
# 0.4 INSTITUTION-SPECIFIC UX
--------------------------------------------------

Every screen should answer:

    "Would this interface make sense to a student
     standing inside the ITVer cafeteria?"

Avoid generic SaaS copy such as:

    "Find a participating restaurant"
    "Select your preferred partner"
    "Choose a pickup location"
    "Nearby participating businesses"

These concepts do not belong in the first version.

Instead, the experience should communicate:

    "Aquí recibes tu contenedor."

    "Aquí puedes devolverlo."

    "Este es el punto de retorno."

The exact copy must be validated against the real
institutional terminology before final implementation.

--------------------------------------------------
# 0.5 INSTITUTIONAL BRAND RELATIONSHIP
--------------------------------------------------

ReVuelta remains the product identity.

The institution provides the physical context.

Do NOT make the UI look like an official ITVer application
unless ReVuelta has formal authorization to represent itself
as such.

The relationship should be visually understandable as:

    ReVuelta
    +
    Instituto Tecnológico de Veracruz
    +
    Cafetería institucional

rather than:

    "generic university sustainability platform."

Use institutional references where useful, but maintain a
clear distinction between:

    ReVuelta brand

and:

    institutional identity.

Do not invent institutional logos, official colors,
department names, policies or endorsements unless they have
been explicitly provided or approved.

--------------------------------------------------
# 0.6 AUTHENTICATION CONTEXT
--------------------------------------------------

Because this is an institutional pilot, authentication should
reflect the actual access model.

If institutional email authentication is part of the approved
flow, use the actual institutional terminology.

Do not design the login as a generic consumer application.

For example, avoid:

    "Create your account"

if the actual model is:

    "Accede con tu cuenta institucional."

Likewise, do not introduce:

- social login;
- arbitrary public registration;
- consumer accounts;

unless explicitly required by the real authentication model.

The prototype must represent how an ITVer student actually
obtains access to ReVuelta.

--------------------------------------------------
# 0.7 CAFETERIA STAFF EXPERIENCE
--------------------------------------------------

The cafeteria interface is not a generic "restaurant dashboard."

It is an operational tool for the staff of the
institutional cafeteria.

Prioritize:

    entregar contenedor
    recibir devolución
    identificar contenedor
    consultar estado
    confirmar recepción

The interface should be optimized for:

    speed
    clarity
    minimal interaction
    physical handoff

The staff should not need to understand ReVuelta's internal
architecture.

They need to know:

    What container is this?
    Who has it?
    Can I give it to this person?
    Can I receive it?
    What do I do next?

--------------------------------------------------
# 0.8 REVUELTA OPERATIONS CONTEXT
--------------------------------------------------

The ReVuelta operations interface is the administrative view
of THIS pilot.

It should answer:

    What is happening with the containers at ITVer?

Not:

    "What is happening across our restaurant network?"

Therefore initial operational views should focus on:

    ITVer inventory
    ITVer containers
    ITVer circulations
    ITVer cafeteria
    ITVer return activity
    ITVer exceptions
    ITVer traceability

Do not create multi-campus selectors or organization
switchers in the first version.

--------------------------------------------------
# 0.9 FUTURE GENERALIZATION
--------------------------------------------------

Architecture should avoid making future expansion impossible,
but the UI and domain model should not prematurely expose
future concepts.

Future possibilities may include:

    multiple campuses
    multiple cafeterias
    multiple partner organizations
    multiple return points
    multiple institutions

However:

    FUTURE MULTI-TENANCY ≠ CURRENT PRODUCT REQUIREMENT

Do not build a generic abstraction merely because it might be
useful someday.

Use the smallest domain model that accurately represents the
current pilot.

If a future-generalization decision affects the architecture,
document it in:

    /docs/decision-log.md

--------------------------------------------------
# 0.10 LANGUAGE RULE
--------------------------------------------------

Use Spanish in the user-facing interface unless the project
explicitly establishes another language.

Use terminology that sounds natural to an ITVer student.

Prefer:

    contenedor
    devolver
    devolución
    cafetería
    punto de retorno
    en uso
    recibido
    validando
    disponible

Avoid unnecessary corporate terminology such as:

    partner ecosystem
    merchant
    vendor
    fulfillment
    asset management
    fleet
    enterprise account

The user should feel that this is a simple institutional
service, not enterprise software.