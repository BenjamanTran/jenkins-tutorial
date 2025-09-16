#!/bin/bash

# Strict mode for safer bash execution
set -Eeuo pipefail
IFS=$'\n\t'

echo "🔧 Setting up Jenkins configuration..."

# Ensure Jenkins home directory exists
mkdir -p jenkins_home

# Write core Jenkins config only if missing (idempotent)
if [ ! -f jenkins_home/config.xml ]; then
cat > jenkins_home/config.xml << 'EOF'
<?xml version='1.1' encoding='UTF-8'?>
<hudson>
  <disabledAdministrativeMonitors/>
  <version>2.516.2</version>
  <numExecutors>2</numExecutors>
  <mode>NORMAL</mode>
  <useSecurity>true</useSecurity>
  <authorizationStrategy class="hudson.security.FullControlOnceLoggedInAuthorizationStrategy">
    <denyAnonymousReadAccess>true</denyAnonymousReadAccess>
  </authorizationStrategy>
  <securityRealm class="hudson.security.HudsonPrivateSecurityRealm">
    <disableSignup>false</disableSignup>
    <enableCaptcha>false</enableCaptcha>
  </securityRealm>
  <disableRememberMe>false</disableRememberMe>
  <projectNamingStrategy class="jenkins.model.ProjectNamingStrategy$DefaultProjectNamingStrategy"/>
  <workspaceDir>${JENKINS_HOME}/workspace/${ITEM_FULL_NAME}</workspaceDir>
  <buildsDir>${ITEM_ROOTDIR}/builds</buildsDir>
  <markupFormatter class="hudson.markup.EscapedMarkupFormatter"/>
  <jdks/>
  <viewsTabBar class="hudson.views.DefaultViewsTabBar"/>
  <myViewsTabBar class="hudson.views.DefaultMyViewsTabBar"/>
  <clouds/>
  <scmCheckoutRetryCount>0</scmCheckoutRetryCount>
  <views>
    <hudson.model.AllView>
      <owner class="hudson" reference="../../.."/>
      <name>all</name>
      <filterExecutors>false</filterExecutors>
      <filterQueue>false</filterQueue>
      <properties class="hudson.model.View$PropertyList"/>
    </hudson.model.AllView>
  </views>
  <primaryView>all</primaryView>
  <slaveAgentPort>-1</slaveAgentPort>
  <label></label>
  <crumbIssuer class="hudson.security.csrf.DefaultCrumbIssuer">
    <excludeClientIPFromCrumb>false</excludeClientIPFromCrumb>
  </crumbIssuer>
  <nodeProperties/>
  <globalNodeProperties/>
</hudson>
EOF
  echo "✅ Created jenkins_home/config.xml"
else
  echo "ℹ️ Found existing jenkins_home/config.xml (skipped)"
fi

# Ensure admin user exists (idempotent). Default password: 'password'
if [ ! -f jenkins_home/users/admin/config.xml ]; then
  mkdir -p jenkins_home/users/admin
  cat > jenkins_home/users/admin/config.xml << 'EOF'
<?xml version='1.1' encoding='UTF-8'?>
<user>
  <fullName>Admin User</fullName>
  <description>Administrator user</description>
  <properties>
    <hudson.security.HudsonPrivateSecurityRealm_-Details>
      <passwordHash>#jbcrypt:$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi</passwordHash>
    </hudson.security.HudsonPrivateSecurityRealm_-Details>
  </properties>
</user>
EOF
  echo "✅ Created admin user (default password: password)"
else
  echo "ℹ️ Admin user already exists (skipped)"
fi

echo "ℹ️ Skipping users.xml creation (managed by Jenkins automatically)"
echo "👤 Available user: admin"
