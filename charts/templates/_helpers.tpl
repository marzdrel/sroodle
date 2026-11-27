{{- define "sroodle.secretName" -}}
{{- default (printf "%s-secrets" .Release.Name) .Values.secrets.existingSecret -}}
{{- end -}}

{{- define "base-container" -}}
image: "{{ .Values.image.repository }}:{{ required "image.tag is required (use an immutable tag such as the git SHA)" .Values.image.tag }}"
imagePullPolicy: {{ .Values.image.pullPolicy }}
ports:
  - containerPort: 80
    name: http
env:
  - name: RAILS_ENV
    value: production
  - name: RAILS_MASTER_KEY
    valueFrom:
      secretKeyRef:
        name: {{ include "sroodle.secretName" . }}
        key: rails-master-key
  - name: APP_HOST
    value: {{ .Values.ingress.host | quote }}
  - name: SOLID_QUEUE_IN_PUMA
    value: "true"
  {{- with .Values.smtp }}
  {{- if .address }}
  - name: SMTP_ADDRESS
    value: {{ .address | quote }}
  - name: SMTP_PORT
    value: {{ .port | quote }}
  {{- with .domain }}
  - name: SMTP_DOMAIN
    value: {{ . | quote }}
  {{- end }}
  {{- with .username }}
  - name: SMTP_USERNAME
    value: {{ . | quote }}
  {{- end }}
  {{- with .mailFrom }}
  - name: MAIL_FROM
    value: {{ . | quote }}
  {{- end }}
  - name: SMTP_PASSWORD
    valueFrom:
      secretKeyRef:
        name: {{ include "sroodle.secretName" $ }}
        key: smtp-password
        optional: true
  {{- end }}
  {{- end }}
volumeMounts:
  - name: sqlite-storage
    mountPath: {{ .Values.storage.mountPath }}
resources:
  {{- toYaml .Values.resources | nindent 2 }}
{{- end -}}
