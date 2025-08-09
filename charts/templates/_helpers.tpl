{{- define "base-container" -}}
image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
ports:
  - containerPort: 80
    name: http
env:
  - name: RAILS_ENV
    value: production
  - name: RAILS_MASTER_KEY
    valueFrom:
      secretKeyRef:
        name: {{ .Release.Name }}-secrets
        key: rails-master-key
volumeMounts:
  - name: sqlite-storage
    mountPath: {{ .Values.storage.mountPath }}
resources:
  requests:
    memory: 1Gi
    cpu: 500m
  limits:
    memory: 1Gi
    cpu: 500m
{{- end -}}

